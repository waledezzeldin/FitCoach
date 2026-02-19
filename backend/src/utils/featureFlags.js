const toBool = (value) => {
  if (typeof value === 'boolean') return value;
  if (typeof value !== 'string') return false;
  const normalized = value.trim().toLowerCase();
  return ['1', 'true', 'yes', 'on'].includes(normalized);
};

const isEnabled = (envKey) => toBool(process.env[envKey]);
const isBypassEnabled = (featureKey) => isEnabled(featureKey);

module.exports = {
  isEnabled,
  isBypassEnabled
};
