const GROQ_URL = 'https://api.groq.com/openai/v1/chat/completions';

export const GROQ_TEXT_MODEL =
  process.env.GROQ_TEXT_MODEL || 'llama-3.3-70b-versatile';
export const GROQ_VISION_MODEL =
  process.env.GROQ_VISION_MODEL || 'qwen/qwen3.6-27b';

function wait(ms) {
  return new Promise((resolve) => setTimeout(resolve, ms));
}

export async function runGroqJson({
  model,
  messages,
  maxTokens = 8192,
  temperature = 0.1,
}) {
  const apiKey = process.env.GROQ_API_KEY;
  if (!apiKey) {
    throw new Error('GROQ_API_KEY is not configured on the server.');
  }

  let lastError = null;

  for (let attempt = 0; attempt < 4; attempt += 1) {
    const response = await fetch(GROQ_URL, {
      method: 'POST',
      headers: {
        Authorization: `Bearer ${apiKey}`,
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        model,
        messages,
        max_tokens: maxTokens,
        temperature,
        response_format: { type: 'json_object' },
        ...(model === 'qwen/qwen3.6-27b'
          ? { reasoning_effort: 'none', reasoning_format: 'hidden' }
          : {}),
      }),
      cache: 'no-store',
    });

    if (response.ok) {
      const data = await response.json();
      const raw = data.choices?.[0]?.message?.content;
      if (!raw) throw new Error('Groq returned an empty response.');

      try {
        return {
          data: JSON.parse(raw),
          usage: data.usage || null,
          model: data.model || model,
        };
      } catch {
        throw new Error('Groq returned invalid structured data. Please retry this batch.');
      }
    }

    const detail = await response.text();
    lastError = new Error(`Groq request failed (${response.status}): ${detail}`);

    if (response.status !== 429 && response.status < 500) break;

    const retryAfter = Number(response.headers.get('retry-after'));
    const delay = Number.isFinite(retryAfter)
      ? retryAfter * 1000
      : Math.min(15000, 1200 * 2 ** attempt);
    await wait(delay);
  }

  throw lastError || new Error('Groq request failed.');
}
