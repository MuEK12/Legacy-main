/**
 * Configura o tema dinamicamente, escrevendo as CSS variables que o Tailwind
 * usa (--main, --mainHover, --mainLight, --from, --to). Todas as variações
 * são derivadas da cor principal para que o painel mantenha o tema coerente.
 *
 * @param {string} mainColor - Cor principal do tema em hexadecimal (#rrggbb)
 */
export default function setTheme(mainColor) {
  const root = document.documentElement;

  const hexToRgb = (hex) => {
    const result = /^#?([a-f\d]{2})([a-f\d]{2})([a-f\d]{2})$/i.exec(hex);
    return result
      ? {
          r: parseInt(result[1], 16),
          g: parseInt(result[2], 16),
          b: parseInt(result[3], 16),
        }
      : null;
  };

  const toVar = ({ r, g, b }) => `${r} ${g} ${b}`;

  const lighten = ({ r, g, b }, pct) => ({
    r: Math.round(r + (255 - r) * pct),
    g: Math.round(g + (255 - g) * pct),
    b: Math.round(b + (255 - b) * pct),
  });

  const rgb = hexToRgb(mainColor);
  if (rgb) {
    const { r, g, b } = rgb;

    root.style.setProperty("--main", toVar(rgb));
    root.style.setProperty(
      "--mainHover",
      toVar({ r: Math.round(r * 0.75), g: Math.round(g * 0.75), b: Math.round(b * 0.75) }),
    );
    root.style.setProperty("--mainLight", toVar(lighten(rgb, 0.4)));
    root.style.setProperty(
      "--from",
      toVar({ r: Math.round(r * 0.07), g: Math.round(g * 0.11), b: Math.round(b * 0.01) }),
    );
    root.style.setProperty(
      "--to",
      toVar({ r: Math.round(r * 0.12), g: Math.round(g * 0.18), b: Math.round(b * 0.02) }),
    );

    // Cores de aceitar/rejeitar derivadas do tema
    root.style.setProperty(
      "--accept-background",
      toVar({ r: Math.round(r * 0.62), g: Math.round(g * 0.95), b: Math.round(b * 0.6) }),
    );
    root.style.setProperty(
      "--accept-backgroundHover",
      toVar({ r: Math.round(r * 0.5), g: Math.round(g * 0.76), b: Math.round(b * 0.48) }),
    );
    root.style.setProperty("--accept-letter", toVar(lighten(rgb, 0.6)));
  }
}
