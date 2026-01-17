module.exports = {
  root: true,
  env: {
    browser: true,
    es2022: true,
    node: true
  },
  extends: [
    'eslint:recommended',
    'plugin:vue/vue3-recommended',
    'prettier'
  ],
  parserOptions: {
    ecmaVersion: 'latest',
    sourceType: 'module'
  },
  rules: {
    // Allow unused vars prefixed with underscore
    'no-unused-vars': ['warn', { argsIgnorePattern: '^_', varsIgnorePattern: '^_' }],
    // Vue specific rules
    'vue/multi-word-component-names': 'off',
    'vue/no-v-html': 'off',
    // Allow console in development
    'no-console': process.env.NODE_ENV === 'production' ? 'warn' : 'off',
    'no-debugger': process.env.NODE_ENV === 'production' ? 'error' : 'off'
  },
  ignorePatterns: [
    'dist/',
    '.vitepress/cache/',
    'node_modules/',
    '*.min.js'
  ]
}
