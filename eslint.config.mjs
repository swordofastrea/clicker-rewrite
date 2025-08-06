import markdown from "@eslint/markdown";
import style from "@isentinel/eslint-config";

export default style({
	gitignore: true,
	ignores: ["node_modules", "out", "dist"],
	jsdoc: false,
	jsx: true,
	languageOptions: {
		parserOptions: {
			project: ["./tsconfig.json"],
			tsconfigRootDir: import.meta.dirname,
		},
	},
	overrides: [
		{
			extends: ["plugin:markdown/recommended"],
			files: ["**/*.md"],
			plugins: { markdown },
		},
	],
	roblox: true,
	rules: {
		"antfu/consistent-list-newline": "off",
		"curly": "off",
		"max-lines-per-function": "off",
		"roblox/lua-truthiness": "off",
		"shopify/prefer-module-scope-constants": "off",
		"style/jsx-sort-props": "off",
		"test/valid-expect": "off",
		"ts/no-confusing-void-expression": "off",
		"ts/no-misused-promises": "off",
		"ts/no-non-null-assertion": "off",
		"ts/no-redundant-type-constituents": "off",
		"ts/no-unnecessary-type-assertion": "off",
		"ts/no-unsafe-argument": "off",
		"ts/no-unsafe-assignment": "off",
		"ts/no-unsafe-call": "off",
		"ts/no-unsafe-member-access": "off",
		"ts/no-unsafe-return": "off",
		"ts/no-unused-expressions": "off",
		"ts/only-throw-error": "off",
		"ts/strict-boolean-expressions": "off",
		"unicorn/prefer-logical-operator-over-ternary": "off",
	},
	spellCheck: true,
	test: true,
	type: "game",
});
