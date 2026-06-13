const defaultNormalizeText = (value) => String(value ?? "").trim();

const evaluateRules = ({ rules, context }) => {
  const safeRules = Array.isArray(rules) ? rules : [];
  const safeContext = {
    ...context,
    normalizeText:
      typeof context?.normalizeText === "function"
        ? context.normalizeText
        : defaultNormalizeText,
  };

  return safeRules
    .filter((rule) => {
      try {
        return !rule.validate(safeContext);
      } catch (err) {
        console.error(
          "[rule-engine:validate-error]",
          JSON.stringify({
            code: rule?.code ?? "unknown_rule",
            message: err?.message || String(err),
          }),
        );
        return true;
      }
    })
    .map((rule) => ({
      code: rule.code,
      message: rule.message,
      severity: rule.severity || "hard",
    }));
};

module.exports = {
  defaultNormalizeText,
  evaluateRules,
};
