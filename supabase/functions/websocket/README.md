# WebSocket Edge Function

Supabase Edge Function with WebSocket support for real-time communication.

## Function Details

- **Path:** `/functions/websocket/`
- **Endpoint:** `https://api.supabase.freqkflag.co/functions/v1/websocket`
- **Type:** WebSocket server
- **Runtime:** Deno

## Features

- WebSocket upgrade handling
- Client connection management
- Message echo with timestamp
- Welcome message on connect

## Usage

### Connect via WebSocket

```javascript
const ws = new WebSocket('wss://api.supabase.freqkflag.co/functions/v1/websocket');

ws.onopen = () => {
  console.log('Connected!');
};

ws.onmessage = (event) => {
  console.log('Received:', event.data);
};

ws.send('Hello from client!');
```

### Test with curl

```bash
# Note: curl doesn't support WebSocket, use a WebSocket client instead
# For testing, use wscat or a browser WebSocket client
```

## Deployment

For self-hosted Supabase, Edge Functions need to be deployed using:

1. **Supabase CLI** (recommended):
   ```bash
   supabase functions deploy websocket
   ```

2. **Manual deployment** (if Functions service is configured):
   - Copy function files to Supabase Functions service
   - Restart the service

## Configuration

The function uses:
- `jsr:@supabase/functions-js/edge-runtime.d.ts` for type definitions
- Deno's built-in WebSocket upgrade support

## Notes

- WebSocket connections require proper upgrade handling
- The function responds to WebSocket upgrade requests
- Non-WebSocket requests return an error message
- Timestamps are sent in ISO format

