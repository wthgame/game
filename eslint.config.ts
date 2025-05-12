import tsPlugin from "@typescript-eslint/eslint-plugin";
import tsParser from "@typescript-eslint/parser";
import prettierPlugin from "eslint-plugin-prettier";
import roblox from "eslint-plugin-roblox-ts-x";
import importsPlugin from "eslint-plugin-simple-import-sort";

export default [
	roblox.config.recommended,
	{
		files: ["**/*.ts", "**/*.tsx"],
		plugins: {
			"@typescript-eslint": tsPlugin,
			import: importsPlugin,
			prettier: prettierPlugin,
		},
		languageOptions: {
			parser: tsParser,
			parserOptions: {
				project: "tsconfig.build.json",
				sourceType: "module",
			},
		},
		rules: {
			"no-unused-vars": "off",
			"no-undef": "off",
			"no-shadow": "off",
			"import/no-unresolved": "off",
			"import/named": "warn",
			"prettier/prettier": "error",
		},
	},
];
