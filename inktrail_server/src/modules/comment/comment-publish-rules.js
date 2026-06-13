const { evaluateRules } = require("../../core/rules/rule-engine");
const {
  containsAnyPhrase,
} = require("../../core/rules/rule-matchers");
const {
  PROFANITY_LOOSE_PHRASES,
  COMMENT_HARD_BLOCK_LOOSE_PHRASES,
} = require("../../core/rules/sensitive-keyword-phrases");

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

const hasProfanity = ({ content, normalizeText }) =>
  containsAnyPhrase({
    text: content,
    phrases: PROFANITY_LOOSE_PHRASES,
    normalizeText,
    mode: "loose",
  });

const hasHardBlockPhrase = ({ content, normalizeText }) =>
  containsAnyPhrase({
    text: content,
    phrases: COMMENT_HARD_BLOCK_LOOSE_PHRASES,
    normalizeText,
    mode: "loose",
  });

const COMMENT_PUBLISH_RULES = [
  {
    code: "COMMENT_SUSPICIOUS_URL",
    message: "Bình luận không được chứa liên kết trang web.",
    severity: "hard",
    validate: ({ content }) => !hasSuspiciousUrl(content),
  },
  {
    code: "COMMENT_PHONE_LIKE",
    message:
      "Bình luận có dấu hiệu chứa số điện thoại hoặc thông tin liên hệ không phù hợp.",
    severity: "hard",
    validate: ({ content }) => !hasPhoneLike(content),
  },
  {
    code: "COMMENT_EXCESSIVE_REPETITION",
    message: "Bình luận có ký tự lặp lại quá nhiều lần.",
    severity: "hard",
    validate: ({ content }) => !hasExcessiveCharRepetition(content),
  },
  {
    code: "COMMENT_PROFANITY",
    message:
      "Bình luận có ngôn từ tục tĩu hoặc công kích quá mức. Bạn vui lòng chỉnh sửa.",
    severity: "hard",
    validate: ({ content, normalizeText }) =>
      !hasProfanity({ content, normalizeText }),
  },
  {
    code: "COMMENT_HARD_BLOCK_KEYWORD",
    message:
      "Bình luận có dấu hiệu mời gọi, giao dịch, hướng dẫn, hoặc nội dung độc hại không phù hợp.",
    severity: "hard",
    validate: ({ content, normalizeText }) =>
      !hasHardBlockPhrase({ content, normalizeText }),
  },
];

const evaluateCommentPublishRules = ({ content, normalizeText }) =>
  evaluateRules({
    rules: COMMENT_PUBLISH_RULES,
    context: { content, normalizeText },
  });

module.exports = {
  COMMENT_PUBLISH_RULES,
  evaluateCommentPublishRules,
};
