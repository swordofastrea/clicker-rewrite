import tsParser from '@typescript-eslint/parser';

export default [
  {
    languageOptions: {
      parser: tsParser,
      parserOptions: {
        ecmaVersion: 2018,
        sourceType: 'module',
        jsx: true,
        project: './tsconfig.json',
      },
    },
    ignores: ['/out'],
  },
  {
    rules: {
      'antfu/consistent-list-newline': 'off',
      curly: 'off',
      'max-lines-per-function': 'off',
      'roblox/lua-truthiness': 'off',
      'ts/no-confusing-void-expression': 'off',
      'ts/no-non-null-assertion': 'off',
      'ts/no-redundant-type-constituents': 'off',
      'ts/no-unnecessary-type-assertion': 'off',
      'ts/no-unsafe-argument': 'off',
      'ts/no-unsafe-assignment': 'off',
      'ts/no-unsafe-call': 'off',
      'ts/no-unsafe-member-access': 'off',
      'ts/no-unsafe-return': 'off',
      'ts/no-unused-expressions': 'off',
      'ts/only-throw-errors': 'off',
      'ts/strict-boolean-expressions': 'off',
      'unicorn/prefer-logical-operator-over-ternary': 'off',
      'react/no-create-ref': 'off',
      'ts/no-misused-promises': 'off',
      'test/valid-expect': 'off',
    },
  },
];
