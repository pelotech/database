import { Hono } from 'hono';
import { generateKeyPair, JSONWebKeySet, JWK, calculateJwkThumbprintUri } from 'jose';
import { GenerateKeyPairResult } from 'jose/key/generate/keypair';
import { exportJWK } from "jose/key/export";
import { SignJWT } from "jose/jwt/sign";
import { cors } from 'hono/cors';

const path = Deno.env.get('PGRST_JWT_SECRET')?.replace('@', '') ?? '/tmp/jwks.json';
const claims = JSON.parse(Deno.env.get('PGRST_JWT_CLAIMS') ?? '{}');
const origin = Deno.env.get('PGRST_CLIENT_ORIGIN')?.split(',') ?? [];
const trusted = Deno.env.get('PGRST_JWK_TRUST')?.split(',') ?? [];
const cert = Deno.env.get('PGRST_JWK_CERT') ?? 'cert.pem';
const alg = Deno.env.get('PGRST_JWT_ALG') ?? 'RS256';
const iss = Deno.env.get('PGRST_JWT_ISS') ?? 'http://localhost:8000'
const aud = Deno.env.get('PGRST_JWT_AUD') ?? 'postgrest';
const exp = Deno.env.get('PGRST_JWT_EXP') ?? '5 minutes';
const sub = Deno.env.get('PGRST_JWT_SUB') ?? 'anon';
const api = Deno.env.get('PGRST_CLIENT_KEY') ?? '';
const typ = 'JWT';
const jwks_uri = Deno.env.get('PGRST_JWKS_URI') ?? 'http://localhost:8000/jwks'

let keypair: GenerateKeyPairResult;
const initialize = async () => {
    keypair = await generateKeyPair(alg, { extractable: true });
    const keysets = await jwk(keypair.publicKey, ...await upstream());

    keysets.keys[0].kid = await calculateJwkThumbprintUri(keysets.keys[0])

    await write(keysets);
    localStorage.setItem('jwk:kid', keysets.keys[0].kid);
    localStorage.setItem('jwk:set', JSON.stringify(keysets))
}

const upstream = async (): Promise<Array<JWK>> => {
    const certificate = await Deno.readTextFile(cert).catch((error) => {
        console.warn(error)
        return undefined
    })
    const caCerts = certificate ? [certificate] : [];

    const client = Deno.createHttpClient({ caCerts })

    const keyset = new Array<JWK>();

    for await (const address of trusted) {
        try {
            const response = await fetch(address, { client })
            const data = await response.json() as JSONWebKeySet;
            keyset.push(...data.keys)
        } catch (error) {
            console.warn(error)
        }
    }

    return keyset;
}

const jwk = async (key: CryptoKey, ...jwks: Array<JWK>): Promise<JSONWebKeySet> => {
  const jwk = await exportJWK(key);

  const keys = [ jwk, ...jwks].filter(value => !!value);

  return { keys }
}

const jwt = async (key: CryptoKey, kid?: string): Promise<string> => await new SignJWT(claims)
  .setProtectedHeader({ alg, kid, typ })
  .setAudience(aud)
  .setIssuedAt()
  .setExpirationTime(exp)
  .setSubject(sub)
  .setIssuer(iss)
  .sign(key);


const write = async (keys: JSONWebKeySet) => {
    const file = await Deno.create(path);
    const encoder = new TextEncoder();
    const data = encoder.encode(JSON.stringify(keys))

    await file.write(data)
}

const app = new Hono();

app.use('/', cors({ origin }))
app.get('/', (context) => context.redirect('/.well-known/openid-configuration', 301));

app.use('/.well-known/openid-configuration', cors({ origin }))
app.get('/.well-known/openid-configuration', (context) => context.json({jwks_uri}))

app.use('/jwks', cors({ origin }))
app.get('/jwks', (context) => {
  const keyset = localStorage.getItem('jwk:set');

  if (keyset) return context.json(JSON.parse(keyset));

  return context.json({message:'not found'}, 404);
});

app.use('/peek', cors({ origin }))
app.get('/peek', async (context) => {
  const auth = context.req.header('Authorization')?.replace('Bearer ', '');

  if (api && api != auth) return context.json({message:'not authorized'}, 401)

  const kid = localStorage.getItem('jwk:kid') ?? '';

  return context.json({ access_token: await jwt(keypair.privateKey, kid) })
});

initialize().finally(() => console.log(`initialized application with kid ${localStorage.getItem('kid')}`));

Deno.serve(app.fetch);