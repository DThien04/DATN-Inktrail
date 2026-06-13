const { evaluateRules } = require("../../core/rules/rule-engine");
const {
  containsAnyPhrase,
} = require("../../core/rules/rule-matchers");
const {
  PROFANITY_LOOSE_PHRASES,
  STORY_METADATA_SPAM_LOOSE_PHRASES,
} = require("../../core/rules/sensitive-keyword-phrases");

const TITLE_MIN_LEN = 3;
const DESCRIPTION_MIN_LEN = 25;

const hasProfanity = ({ title, description, normalizeText }) =>
  containsAnyPhrase({
    text: `${title} ${description}`,
    phrases: PROFANITY_LOOSE_PHRASES,
    normalizeText,
    mode: "loose",
  });

const hasMetadataSpamPhrase = ({ title, description, normalizeText }) =>
  containsAnyPhrase({
    text: `${title} ${description}`,
    phrases: STORY_METADATA_SPAM_LOOSE_PHRASES,
    normalizeText,
    mode: "loose",
  });

const hasSuspiciousUrl = (text) =>
  /\bhttps?:\/\//i.test(text) || /\bwww\.\S+/i.test(text);

const hasPhoneLike = (text) => {
  const compact = String(text ?? "").replace(/[\s\-.()]/g, "");
  return /(?:\+84|84|0)(?:3|5|7|8|9)\d{8,}/.test(compact);
};

const hasExcessiveCharRepetition = (text) => {
  const t = String(text ?? "");
  return /([\p{L}\d])\1{7,}/u.test(t);
};

const STORY_PUBLISH_RULES = [
  {
    code: "TITLE_TOO_SHORT",
    message: "Tiêu đề xuất bản cần rõ ràng hơn.",
    severity: "hard",
    validate: ({ title, normalizeText }) =>
      normalizeText(title).length >= TITLE_MIN_LEN,
  },
  {
    code: "TITLE_SUSPICIOUS_URL",
    message: "Tiêu đề không nên chứa liên kết trang web.",
    severity: "hard",
    validate: ({ title }) => !hasSuspiciousUrl(title),
  },
  {
    code: "TITLE_PHONE_LIKE",
    message: "Tiêu đề có dấu hiệu chứa số điện thoại hoặc thông tin liên hệ.",
    severity: "hard",
    validate: ({ title }) => !hasPhoneLike(title),
  },
  {
    code: "TITLE_EXCESSIVE_REPETITION",
    message: "Tiêu đề có ký tự lặp lại quá nhiều lần.",
    severity: "hard",
    validate: ({ title }) => !hasExcessiveCharRepetition(title),
  },
  {
    code: "TEXT_SUSPICIOUS_URL",
    message: "Truyện không nên chứa liên kết trong tiêu đề hoặc mô tả.",
    severity: "hard",
    validate: ({ title, description }) =>
      !hasSuspiciousUrl(title) && !hasSuspiciousUrl(description),
  },
  {
    code: "TEXT_PHONE_LIKE",
    message: "Truyện có dấu hiệu chứa số điện thoại hoặc thông tin liên hệ.",
    severity: "hard",
    validate: ({ title, description }) =>
      !hasPhoneLike(title) && !hasPhoneLike(description),
  },
  {
    code: "TEXT_EXCESSIVE_REPETITION",
    message: "Tiêu đề hoặc mô tả có ký tự lặp lại quá nhiều lần.",
    severity: "hard",
    validate: ({ title, description }) =>
      !hasExcessiveCharRepetition(title) &&
      !hasExcessiveCharRepetition(description),
  },
  {
    code: "DESCRIPTION_TOO_SHORT",
    message: "Truyện xuất bản nên có mô tả rõ ràng hơn.",
    severity: "hard",
    validate: ({ description, normalizeText }) =>
      normalizeText(description).length >= DESCRIPTION_MIN_LEN,
  },
  {
    code: "MISSING_TAG",
    message: "Truyện cần ít nhất một tag trước khi xuất bản.",
    severity: "hard",
    validate: ({ tagCount = 0 }) => tagCount > 0,
  },
  {
    code: "METADATA_SPAM_KEYWORD",
    message:
      "Tiêu đề hoặc mô tả có dấu hiệu quảng cáo, mời gọi, hoặc nội dung spam không phù hợp.",
    severity: "hard",
    validate: ({ title, description, normalizeText }) =>
      !hasMetadataSpamPhrase({ title, description, normalizeText }),
  },
  {
    code: "PROFANITY",
    message:
      "Tiêu đề hoặc mô tả có ngôn từ tục tĩu hoặc công kích quá mức.",
    severity: "hard",
    validate: ({ title, description, normalizeText }) =>
      !hasProfanity({ title, description, normalizeText }),
  },
];

const evaluateStoryPublishRules = ({
  title,
  description,
  tagCount,
  normalizeText,
}) =>
  evaluateRules({
    rules: STORY_PUBLISH_RULES,
    context: {
      title,
      description,
      tagCount,
      normalizeText,
    },
  });

module.exports = {
  STORY_PUBLISH_RULES,
  evaluateStoryPublishRules,
};
