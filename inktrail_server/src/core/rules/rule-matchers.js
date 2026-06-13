const normalizeTextBase = (value, normalizeText) =>
  (typeof normalizeText === "function"
    ? normalizeText(value)
    : String(value ?? "").trim()
  ).toLowerCase();

const normalizeForExactPhraseMatch = (value, normalizeText) =>
  normalizeTextBase(value, normalizeText)
    .normalize("NFC")
    .replace(/[^\p{L}\p{N}\s]/gu, " ")
    .replace(/\s+/g, " ")
    .trim();

const normalizeForLoosePhraseMatch = (value, normalizeText) =>
  normalizeTextBase(value, normalizeText)
    .normalize("NFD")
    .replace(/[\u0300-\u036f]/g, "")
    .replace(/[^\p{L}\p{N}\s]/gu, " ")
    .replace(/\s+/g, " ")
    .trim();

const normalizePhraseList = (phrases, normalizer) =>
  [...new Set(
    (Array.isArray(phrases) ? phrases : [])
      .map((phrase) => normalizer(phrase))
      .filter(Boolean),
  )];

const containsAnyPhrase = ({
  text,
  phrases,
  normalizeText,
  mode = "exact",
}) => {
  const normalizer =
    mode === "loose"
      ? (value) => normalizeForLoosePhraseMatch(value, normalizeText)
      : (value) => normalizeForExactPhraseMatch(value, normalizeText);

  const haystack = ` ${normalizer(text)} `;
  return normalizePhraseList(phrases, normalizer).some((phrase) =>
    haystack.includes(` ${phrase} `),
  );
};

module.exports = {
  normalizeForExactPhraseMatch,
  normalizeForLoosePhraseMatch,
  containsAnyPhrase,
};
