# Supabase Ask Assistant Configuration

## Overview

The Ask Assistant feature in Supabase Studio has been configured to use AI providers for database assistance and query generation.

## Configuration

### Environment Variables

The following environment variables are configured in `docker-compose.yml`:

- **`ANTHROPIC_API_KEY`**: Anthropic Claude API key (primary provider)
- **`OPENAI_API_KEY`**: OpenAI API key (alternative provider)
- **`ENABLE_AI_FEATURES`**: Set to `"true"` to enable AI features in Studio
- **`OPENAI_API_BASE_URL`**: (Optional) Custom API endpoint for Cursor Client or LocalAI

### Current Setup

1. **Anthropic Claude** is configured as the primary AI provider
2. **OpenAI** is available as an alternative
3. AI features are enabled in Studio

### Using Cursor Client

If you want to use Cursor Client specifically, you can:

1. **Option 1: Use Cursor's API endpoint** (if available)
   ```yaml
   OPENAI_API_BASE_URL: https://api.cursor.com/v1  # Replace with actual Cursor API endpoint
   OPENAI_API_KEY: <cursor-api-key>
   ```

2. **Option 2: Use LocalAI** (if you have LocalAI running)
   ```yaml
   OPENAI_API_BASE_URL: https://localai.freqkflag.co/v1
   OPENAI_API_KEY: not-needed  # LocalAI may not require a key
   ```

3. **Option 3: Use Anthropic** (current setup)
   ```yaml
   ANTHROPIC_API_KEY: ${ANTHROPIC_API_KEY}
   ```

## Verification

To verify the configuration:

1. **Check environment variables in container:**
   ```bash
   cd /root/infra/supabase
   docker compose exec supabase-studio env | grep -i "ANTHROPIC\|OPENAI\|AI"
   ```

2. **Access Supabase Studio:**
   - Navigate to `https://supabase.freqkflag.co`
   - Look for the "Ask Assistant" feature in the Studio interface
   - Test by asking a question about your database schema

## Troubleshooting

### Ask Assistant Not Appearing

1. **Check if AI features are enabled:**
   ```bash
   docker compose exec supabase-studio env | grep ENABLE_AI_FEATURES
   ```
   Should output: `ENABLE_AI_FEATURES=true`

2. **Verify API keys are loaded:**
   ```bash
   docker compose exec supabase-studio env | grep -i "ANTHROPIC\|OPENAI"
   ```

3. **Check Studio logs:**
   ```bash
   docker compose logs supabase-studio | grep -i "ai\|assistant\|error"
   ```

### API Key Issues

- Ensure `ANTHROPIC_API_KEY` or `OPENAI_API_KEY` is set in `.workspace/.env`
- Verify the API key is valid and has sufficient credits/quota
- Check if the API key has the necessary permissions

## Updating Configuration

To change the AI provider:

1. Edit `/root/infra/supabase/docker-compose.yml`
2. Update the environment variables in the `supabase-studio` service
3. Restart the service:
   ```bash
   cd /root/infra/supabase
   docker compose up -d supabase-studio
   ```

## Notes

- The Ask Assistant feature requires a valid API key from an AI provider
- Anthropic Claude is currently configured as the primary provider
- OpenAI can be used as an alternative by setting `OPENAI_API_KEY`
- Custom endpoints (like Cursor Client or LocalAI) can be configured via `OPENAI_API_BASE_URL`

**Last Updated:** 2025-11-22

