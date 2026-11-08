// Fuente editable de los SVG. Sin dependencias: node generar_diagramas.cjs
const fs = require('node:fs');
const path = require('node:path');
const escape = (s) => String(s).replace(/[&<>"']/g, (c) =>
  ({'&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;', "'": '&apos;'}[c]));

function render(name, title, width, height, tables, edges = [], extra = '') {
  const byId = new Map(tables.map((t) => [t.id, t]));
  for (const t of tables) t.h = 52 + t.fields.length * 29;
  const links = edges.map(([from, to, label, dashed = false]) => {
    const a = byId.get(from), b = byId.get(to);
    if (!a || !b) throw new Error(`Unknown diagram endpoint: ${from}, ${to}`);
    const x1 = a.x + a.w, y1 = a.y + a.h / 2;
    const x2 = b.x, y2 = b.y + b.h / 2;
    return `<path d="M${x1} ${y1} H${(x1+x2)/2} V${y2} H${x2}"
      fill="none" stroke="#51677d" stroke-width="2" ${dashed ? 'stroke-dasharray="6 4"' : ''}/>
      <text x="${(x1+x2)/2}" y="${(y1+y2)/2-12}" text-anchor="middle" font-size="16"
      fill="#243b53" paint-order="stroke" stroke="white" stroke-width="5">${escape(label)}</text>`;
  }).join('\n');
  const cards = tables.map((t) => `<g>
    <rect x="${t.x}" y="${t.y}" width="${t.w}" height="${t.h}" rx="7" fill="#f7fafc" stroke="#51677d" stroke-width="2"/>
    <path d="M${t.x+7} ${t.y} H${t.x+t.w-7} Q${t.x+t.w} ${t.y} ${t.x+t.w} ${t.y+7}
      V${t.y+38} H${t.x} V${t.y+7} Q${t.x} ${t.y} ${t.x+7} ${t.y}" fill="#244968"/>
    <text x="${t.x+t.w/2}" y="${t.y+25}" text-anchor="middle" font-size="17" font-weight="bold" fill="white">${escape(t.id)}</text>
    ${t.fields.map((f, i) => `<text x="${t.x+13}" y="${t.y+61+i*29}" font-size="17" fill="#152d42">${escape(f)}</text>`).join('\n')}
    </g>`).join('\n');
  const svg = `<svg xmlns="http://www.w3.org/2000/svg" width="${width}" height="${height}" viewBox="0 0 ${width} ${height}" role="img" aria-labelledby="title">
    <title id="title">${escape(title)}</title>
    <rect width="100%" height="100%" fill="white"/>
    <g font-family="Arial, sans-serif">
    <text x="30" y="34" font-size="23" font-weight="bold" fill="#152d42">${escape(title)}</text>
    ${links}${cards}${extra}
    </g></svg>`;
  fs.writeFileSync(path.join(__dirname, `${name}.svg`), svg, 'utf8');
}

render('museo', 'Museo | estado inicial de los retos 5 y 8', 1120, 545, [
  {id: 'r5_ficha', x: 30, y: 80, w: 340, fields: [
    'id_pieza : INTEGER', 'numero_ficha : INTEGER', 'titulo : TEXT',
    'id_sala : INTEGER', 'nombre_sala : TEXT', 'etiquetas : TEXT', 'texto_ficha : TEXT']},
  {id: 'r8_sala', x: 440, y: 80, w: 280, fields: [
    'PK id_sala : INTEGER', 'nombre : TEXT NOT NULL']},
  {id: 'r8_registro_inseguro', x: 790, y: 80, w: 300, fields: [
    'id_registro : INTEGER', 'id_sala : INTEGER', 'codigo : TEXT',
    'fragilidad : NUMERIC(4,1)', 'estado : TEXT']}
], [], `
  <text x="30" y="390" font-size="18">Esquema: mt_museo. Las tablas r5 y r8 son independientes.</text>
  <text x="30" y="425" font-size="18">r5_ficha y r8_registro_inseguro no tienen restricciones declaradas.</text>
  <text x="30" y="460" font-size="18">La referencia a sala en el formulario es un contrato pendiente, no una FK existente.</text>
  <text x="30" y="495" font-size="18">r8_registro_corregido debe crearse en el reto 8; no forma parte del estado inicial.</text>`);

render('mensajeria', 'Mensajeria | tres incidentes, tres conjuntos de tablas', 1120, 970, [
  {id: 'r4_envio', x: 30, y: 80, w: 300, fields: [
    'PK id_envio : INTEGER', 'cliente : TEXT', 'importe : NUMERIC(10,2)']},
  {id: 'r4_evento', x: 450, y: 80, w: 300, fields: [
    'PK id_evento : INTEGER', 'FK id_envio : INTEGER', 'estado : TEXT']},
  {id: 'r7_cliente', x: 30, y: 360, w: 280, fields: [
    'PK id_cliente : INTEGER', 'nombre : TEXT']},
  {id: 'r7_aviso', x: 430, y: 290, w: 290, fields: [
    'PK id_aviso : INTEGER', 'FK id_cliente : INTEGER NULL']},
  {id: 'r7_baja', x: 430, y: 510, w: 290, fields: [
    'PK/FK id_cliente : INTEGER']},
  {id: 'r9_guia', x: 30, y: 740, w: 320, fields: [
    'PK id_guia : INTEGER', 'fecha : DATE', 'importe : NUMERIC(10,2)']}
], [
  ['r4_envio','r4_evento','1 : 0..N'],
  ['r7_cliente','r7_aviso','1 : 0..N'],
  ['r7_cliente','r7_baja','1 : 0..1']
], `<text x="790" y="110" font-size="18">Esquema: mt_mensajeria</text>
    <text x="790" y="150" font-size="17">Cada evento tiene un envio.</text>
    <text x="770" y="340" font-size="17">Un aviso puede no tener</text>
    <text x="770" y="370" font-size="17">cliente asignado (NULL).</text>
    <text x="420" y="800" font-size="18">r9_guia no depende de r4 ni de r7.</text>
    <text x="420" y="840" font-size="18">Las aristas indican referencias reales.</text>`);

render('reparaciones', 'Reparaciones | estados separados para cada reto', 1120, 1010, [
  {id: 'r6_orden', x: 30, y: 80, w: 300, fields: [
    'PK id_orden : INTEGER', 'estado : TEXT']},
  {id: 'r6_auditoria', x: 470, y: 80, w: 320, fields: [
    'PK id_auditoria : IDENTITY', 'FK id_orden : INTEGER', 'antes : TEXT', 'despues : TEXT']},
  {id: 'r10_orden', x: 30, y: 380, w: 330, fields: [
    'PK id_orden : INTEGER', 'costo_base : NUMERIC(10,2)',
    'total_final : NUMERIC(10,2) NULL', 'estado : TEXT']},
  {id: 'r11_orden', x: 30, y: 760, w: 300, fields: [
    'PK id_orden : INTEGER', 'estado : TEXT']},
  {id: 'r11_borrador', x: 470, y: 650, w: 320, fields: [
    'PK/FK id_orden : INTEGER', 'detalle : TEXT']},
  {id: 'r11_movimiento', x: 470, y: 830, w: 320, fields: [
    'PK id_movimiento : IDENTITY', 'FK id_orden : INTEGER', 'concepto : TEXT']}
], [
  ['r6_orden','r6_auditoria','1 : 0..N'],
  ['r11_orden','r11_borrador','1 : 0..1'],
  ['r11_orden','r11_movimiento','1 : 0..N']
], `<text x="30" y="320" font-size="18">Esquema: mt_reparaciones. r6, r10 y r11 no comparten ordenes.</text>
    <text x="420" y="420" font-size="18">El reto 10 usa sus propias rutinas y datos.</text>
    <text x="420" y="460" font-size="18">El costo base no se sobrescribe al cerrar.</text>`);

render('directorio', 'Directorio | entradas y consulta reutilizable', 1120, 620, [
  {id: 'r2_entrada', x: 30, y: 80, w: 320, fields: [
    'PK id_entrada : INTEGER', 'codigo : TEXT NULL', 'nombre : TEXT']},
  {id: 'r12_proveedor', x: 30, y: 350, w: 320, fields: [
    'PK id_proveedor : INTEGER', 'nombre : TEXT', 'ciudad : TEXT', 'contacto_interno : TEXT']},
  {id: 'r12_directorio (vista)', x: 530, y: 350, w: 350, fields: [
    'id_proveedor : INTEGER', 'nombre : TEXT', 'ciudad : TEXT', 'contacto_interno : TEXT']}
], [['r12_proveedor','r12_directorio (vista)','consulta',true]], `
    <text x="420" y="110" font-size="18">Esquema: mt_directorio</text>
    <text x="420" y="150" font-size="18">La vista inicial incluye una columna ajena al reporte.</text>
    <text x="420" y="190" font-size="18">Linea discontinua: dependencia de consulta, no FK.</text>`);

// Boceto conceptual deliberadamente incorrecto: no es el modelo de referencia.
const conceptual = `<svg xmlns="http://www.w3.org/2000/svg" width="1120" height="620" viewBox="0 0 1120 620" role="img" aria-labelledby="title">
<title id="title">Boceto conceptual defectuoso del museo</title>
<rect width="1120" height="620" fill="white"/>
<g font-family="Arial, sans-serif" fill="#152d42" font-size="19">
<text x="30" y="36" font-size="24" font-weight="bold">Museo | boceto que contradice las reglas</text>
<g fill="none" stroke="#51677d" stroke-width="2">
<path d="M270 180 H450 M650 180 H850 M550 230 V370"/>
<rect x="40" y="130" width="230" height="100" rx="4"/>
<rect x="450" y="130" width="200" height="100" rx="4"/>
<rect x="850" y="130" width="230" height="100" rx="4"/>
<rect x="430" y="370" width="250" height="130" rx="4"/>
<polygon points="325,180 360,155 395,180 360,205" fill="#edf2f7"/>
<polygon points="710,180 750,155 790,180 750,205" fill="#edf2f7"/>
<polygon points="550,270 590,300 550,330 510,300" fill="#edf2f7"/>
</g>
<text x="155" y="166" text-anchor="middle" font-weight="bold">SALA</text>
<text x="155" y="201" text-anchor="middle">id_sala, nombre</text>
<text x="550" y="166" text-anchor="middle" font-weight="bold">PIEZA</text>
<text x="550" y="201" text-anchor="middle">id_pieza, titulo</text>
<text x="965" y="166" text-anchor="middle" font-weight="bold">EXPOSICION</text>
<text x="965" y="201" text-anchor="middle">id_exposicion</text>
<text x="555" y="405" text-anchor="middle" font-weight="bold">INSCRIPCION</text>
<text x="555" y="442" text-anchor="middle">numero (clave unica global)</text>
<text x="555" y="478" text-anchor="middle">texto</text>
<text x="360" y="143" text-anchor="middle">aloja</text>
<text x="750" y="143" text-anchor="middle">exhibe</text>
<text x="610" y="307">tiene</text>
<text x="286" y="169">0..1</text><text x="404" y="169">0..1</text>
<text x="670" y="169">0..N</text><text x="810" y="169">1</text>
<text x="565" y="257">1</text><text x="565" y="357">0..N</text>
<text x="30" y="550">El boceto no tiene entidad MONTAJE ni un lugar para fecha_montaje.</text>
<text x="30" y="585">Intervenga este dibujo segun las reglas del reto 3; no lo copie como solucion.</text>
</g></svg>`;
fs.writeFileSync(path.join(__dirname, 'conceptual_defectuoso.svg'), conceptual, 'utf8');
console.log('Generated 5 local SVG diagrams from this editable source.');
