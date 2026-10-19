/** @type {import('tailwindcss').Config} */
export default {
  content: ["./index.html", "./src/**/*.{vue,js,ts,jsx,tsx}"],
  safelist: ["static"],
  theme: {
    extend: {
      fontFamily: {
        sans: [
          "Manrope",
          "ui-sans-serif",
          "system-ui",
          "sans-serif",
          '"Apple Color Emoji"',
          '"Segoe UI Emoji"',
          '"Segoe UI Symbol"',
          '"Noto Color Emoji"',
        ],
      },
      colors: {
        main: "rgb(var(--main) / <alpha-value>)",
        mainHover: "rgb(var(--mainHover) / <alpha-value>)",
        mainText: "rgb(var(--mainText) / <alpha-value>)",
        from: "rgb(var(--from) / <alpha-value>)",
        to: "rgb(var(--to) / <alpha-value>)",
        // Cores de aceitar/rejeitar — usadas nos botões de ação
        accept: {
          background: "rgb(var(--accept-background) / <alpha-value>)",
          backgroundHover: "rgb(var(--accept-backgroundHover) / <alpha-value>)",
          letter: "rgb(var(--accept-letter) / <alpha-value>)",
        },
        reject: {
          background: "rgb(var(--reject-background) / <alpha-value>)",
          backgroundHover: "rgb(var(--reject-backgroundHover) / <alpha-value>)",
          letter: "rgb(var(--reject-letter) / <alpha-value>)",
        },
        // Cores de status — amarelo (atenção) e verde (sucesso)
        status: {
          yellow: "rgb(var(--status-yellow) / <alpha-value>)",
          yellowBg: "rgb(var(--status-yellowBg) / <alpha-value>)",
          green: "rgb(var(--status-green) / <alpha-value>)",
          greenBg: "rgb(var(--status-greenBg) / <alpha-value>)",
        },
      },
    },
  },
  plugins: [],
};
