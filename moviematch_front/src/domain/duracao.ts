/**
 * Duração no formato do Flutter (projeto_brademo/lib/service/filmeService.dart:50-55):
 * horas inteiras + minutos restantes, sem zero à esquerda. Ex.: 125 → "2h5min".
 * Recebe minutos inteiros e não negativos (garantido pelo mapeador), ou null (A-07).
 */
export function formatarDuracao(minutos: number | null): string {
  if (minutos === null) return 'não informada'
  const horas = Math.floor(minutos / 60)
  const restantes = minutos % 60
  return `${horas}h${restantes}min`
}
