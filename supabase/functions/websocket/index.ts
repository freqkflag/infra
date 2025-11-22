// Setup type definitions for built-in Supabase Runtime APIs
import "jsr:@supabase/functions-js/edge-runtime.d.ts";

Deno.serve((req) => {
  const upgrade = req.headers.get("upgrade") || "";

  if (upgrade.toLowerCase() != "websocket") {
    return new Response("request isn't trying to upgrade to websocket.");
  }

  const { socket, response } = Deno.upgradeWebSocket(req);

  socket.onopen = () => {
    console.log("client connected!");
    socket.send('Welcome to Supabase Edge Functions!');
  };

  socket.onmessage = (e) => {
    console.log("client sent message:", e.data);
    socket.send(new Date().toString());
  };

  return response;
});

