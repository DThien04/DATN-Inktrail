const { evaluateRules } = require("../../core/rules/rule-engine");
const {
  containsAnyPhrase,
} = require("../../core/rules/rule-matchers");
const {
  PROFANITY_LOOSE_PHRASES,
  CHAPTER_DANGEROUS_INSTRUCTION_LOOSE_PHRASES,
  CHAPTER_SOLICITATION_LOOSE_PHRASES,
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

const hasProfanity = ({ title, content, normalizeText }) =>
  containsAnyPhrase({
    text: `${title} ${content}`,
    phrases: PROFANITY_LOOSE_PHRASES,
    normalizeText,
    mode: "loose",
  });

const hasDangerousInstruction = ({ title, content, normalizeText }) =>
  containsAnyPhrase({
    text: `${title} ${content}`,
    phrases: CHAPTER_DANGEROUS_INSTRUCTION_LOOSE_PHRASES,
    normalizeText,
    mode: "loose",
  });

const hasContactCue = ({ title, content }) =>
  /\b(ib|inbox|telegram|tele|zalo|lien he|lh|sdt|so dien thoai|call|add)\b/i.test(
    `${title} ${content}`,
  );

const hasSolicitationSpam = ({ title, content, normalizeText }) =>
  containsAnyPhrase({
    text: `${title} ${content}`,
    phrases: CHAPTER_SOLICITATION_LOOSE_PHRASES,
    normalizeText,
    mode: "loose",
  });

const CHAPTER_PUBLISH_RULES = [
  {
    code: "CHAPTER_SUSPICIOUS_URL",
    message: "Chương không được chứa liên kết trang web.",
    severity: "hard",
    validate: ({ title, content }) =>
      !hasSuspiciousUrl(title) && !hasSuspiciousUrl(content),
  },
  {
    code: "CHAPTER_PHONE_LIKE",
    message:
      "Chương có dấu hiệu chứa số điện thoại hoặc thông tin liên hệ không phù hợp.",
    severity: "hard",
    validate: ({ title, content }) =>
      !hasPhoneLike(title) && !hasPhoneLike(content),
  },
  {
    code: "CHAPTER_EXCESSIVE_REPETITION",
    message: "Chương có ký tự lặp lại quá nhiều lần.",
    severity: "hard",
    validate: ({ title, content }) =>
      !hasExcessiveCharRepetition(title) &&
      !hasExcessiveCharRepetition(content),
  },
  {
    code: "CHAPTER_PROFANITY",
    message:
      "Chương có ngôn từ tục tĩu hoặc công kích quá mức. Bạn vui lòng chỉnh sửa trước khi xuất bản.",
    severity: "hard",
    validate: ({ title, content, normalizeText }) =>
      !hasProfanity({ title, content, normalizeText }),
  },
  {
    code: "CHAPTER_DANGEROUS_INSTRUCTION",
    message:
      "Chương có dấu hiệu hướng dẫn, giao dịch, hoặc cổ vũ nội dung nguy hiểm trong đời thực.",
    severity: "hard",
    validate: ({ title, content, normalizeText }) =>
      !hasDangerousInstruction({ title, content, normalizeText }),
  },
  {
    code: "CHAPTER_SOLICITATION_SPAM",
    message:
      "Chương có dấu hiệu mời gọi, quảng cáo, hoặc điều hướng sang nội dung không phù hợp.",
    severity: "hard",
    validate: ({ title, content, normalizeText }) =>
      !(hasContactCue({ title, content }) &&
        hasSolicitationSpam({ title, content, normalizeText })),
  },
];

const evaluateChapterPublishRules = ({ title, content, normalizeText }) =>
  evaluateRules({
    rules: CHAPTER_PUBLISH_RULES,
    context: { title, content, normalizeText },
  });

module.exports = {
  CHAPTER_PUBLISH_RULES,
  evaluateChapterPublishRules,
};
