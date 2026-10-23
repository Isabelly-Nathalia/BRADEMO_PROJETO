/**
 * Nota como o Flutter exibe (double.toString do Dart): inteiros com ".0", demais sem arredondar.
 * Ex.: 4 → "4.0", 4.5 → "4.5", 3.75 → "3.75".
 */
export function formatarNota(nota: number): string {
  return Number.isInteger(nota) ? nota.toFixed(1) : String(nota)
}
