import prettier from "eslint-plugin-prettier";
import react from "eslint-plugin-react";
import { fixupPluginRules } from "@eslint/compat";
import globals from "globals";
import tsParser from "@typescript-eslint/parser";
import path from "node:path";
import { fileURLToPath } from "node:url";
import js from "@eslint/js";
import { FlatCompat } from "@eslint/eslintrc";

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);
const compat = new FlatCompat({
    baseDirectory: __dirname,
    recommendedConfig: js.configs.recommended,
    allConfig: js.configs.all
});

export default [...compat.extends("prettier"), {
    ignores: ["/.yarn/**", "/**/node_modules", "/**/*.bundle.*", "/**/*.chunk.*", "/**/*.hot-update.*", "/packages/inferno/**"],
    plugins: {
        prettier,
        react: fixupPluginRules(react),
    },

    languageOptions: {
        globals: {
            ...globals.browser,
            ...globals.node,
            Byond: "readonly",
        },

        parser: tsParser,
        ecmaVersion: 2020,
        sourceType: "module",

        parserOptions: {
            ecmaFeatures: {
                jsx: true,
            },
        },
    },

    settings: {
        "import/resolver": {
            node: {
                extensions: [".js", ".jsx", ".ts", ".tsx"],
            },
        },

        react: {
            version: "16.10",
        },
    },

    rules: {
        "no-async-promise-executor": "error",
        "no-cond-assign": "error",
        "no-debugger": "error",
        "no-dupe-args": "error",
        "no-dupe-keys": "error",
        "no-duplicate-case": "error",
        "no-empty-character-class": "error",
        "no-ex-assign": "error",
        "no-extra-boolean-cast": "error",
        "no-func-assign": "error",
        "no-import-assign": "error",
        "no-inner-declarations": "error",
        "no-invalid-regexp": "error",
        "no-irregular-whitespace": "error",
        "no-misleading-character-class": "error",
        "no-obj-calls": "error",
        "no-prototype-builtins": "error",
        "no-regex-spaces": "error",
        "no-sparse-arrays": "error",
        "no-template-curly-in-string": "error",
        "no-unsafe-finally": "error",
        "no-unsafe-negation": "error",
        "use-isnan": "error",
        "valid-typeof": "error",

        complexity: ["error", {
            max: 50,
        }],

        curly: ["error", "multi-line"],
        eqeqeq: ["error", "always"],
        "no-case-declarations": "error",
        "no-empty-pattern": "error",
        "no-fallthrough": "error",
        "no-global-assign": "error",
        "no-octal": "error",
        "no-octal-escape": "error",
        "no-redeclare": "error",
        "no-return-assign": "error",
        "no-self-assign": "error",
        "no-sequences": "error",
        "no-unused-labels": "warn",
        "no-useless-escape": "warn",
        "no-with": "error",
        radix: "error",
        strict: "error",
        "no-delete-var": "error",
        "no-shadow-restricted-names": "error",
        "no-undef": "error",
        "no-undef-init": "error",
        "func-style": ["error", "expression"],
        "spaced-comment": ["error", "always"],
        "no-class-assign": "error",
        "no-const-assign": "error",
        "no-dupe-class-members": "error",
        "no-new-symbol": "error",
        "no-this-before-super": "error",
        "no-var": "error",
        "prefer-arrow-callback": "error",
        "react/boolean-prop-naming": "error",
        "react/button-has-type": "error",
        "react/default-props-match-prop-types": "error",
        "react/no-access-state-in-setstate": "error",
        "react/no-children-prop": "error",
        "react/no-danger": "error",
        "react/no-danger-with-children": "error",
        "react/no-deprecated": "error",
        "react/no-did-mount-set-state": "error",
        "react/no-did-update-set-state": "error",
        "react/no-direct-mutation-state": "error",
        "react/no-find-dom-node": "error",
        "react/no-is-mounted": "error",
        "react/no-redundant-should-component-update": "error",
        "react/no-render-return-value": "error",
        "react/no-typos": "error",
        "react/no-string-refs": "error",
        "react/no-this-in-sfc": "error",
        "react/no-unescaped-entities": "error",
        "react/no-unsafe": "error",
        "react/no-unused-prop-types": "error",
        "react/no-unused-state": "error",
        "react/no-will-update-set-state": "error",
        "react/prefer-es6-class": "error",
        "react/prefer-stateless-function": "error",
        "react/require-render-return": "error",
        "react/self-closing-comp": "error",
        "react/state-in-constructor": "error",
        "react/style-prop-object": "error",
        "react/void-dom-elements-no-children": "error",
        "react/jsx-boolean-value": "error",
        "react/jsx-handler-names": "error",
        "react/jsx-key": "error",

        "react/jsx-max-depth": ["error", {
            max: 10,
        }],

        "react/jsx-no-comment-textnodes": "error",
        "react/jsx-no-duplicate-props": "error",
        "react/jsx-no-target-blank": "error",
        "react/jsx-no-undef": "error",
        "react/jsx-no-useless-fragment": "error",
        "react/jsx-fragments": "error",
        "react/jsx-pascal-case": "error",
        "react/jsx-uses-react": "error",
        "react/jsx-uses-vars": "error",
    },
}, {
    files: ["**/*.js", "**/*.jsx", "**/*.cjs", "**/*.mjs", "**/*.ts", "**/*.mts", "**/*.cts", "**/*.tsx"],

    rules: {
        "no-undef": "off",
        "react/jsx-no-undef": "off",
    },
}];
