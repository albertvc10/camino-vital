/**
 * TEMPLATE PROCESSOR
 * ==================
 * Función helper para procesar templates de email desde la base de datos
 * Uso en nodos Code de n8n workflows
 */

/**
 * Reemplaza variables en un template HTML
 * @param {string} template - Template HTML con placeholders {{variable}}
 * @param {object} variables - Objeto con las variables a reemplazar
 * @returns {string} HTML con variables reemplazadas
 *
 * @example
 * const html = replaceVariables(
 *   '<h1>{{titulo}}</h1><p>{{nombre}}</p>',
 *   { titulo: 'Hola', nombre: 'Albert' }
 * );
 * // Resultado: '<h1>Hola</h1><p>Albert</p>'
 */
function replaceVariables(template, variables) {
  let result = template;

  // Reemplazar cada variable
  for (const [key, value] of Object.entries(variables)) {
    // Escapar caracteres especiales en el valor para evitar problemas en HTML
    const safeValue = String(value)
      .replace(/&/g, '&amp;')
      .replace(/</g, '&lt;')
      .replace(/>/g, '&gt;')
      .replace(/"/g, '&quot;')
      .replace(/'/g, '&#039;');

    // Reemplazar todas las ocurrencias de {{key}}
    const regex = new RegExp(`\\{\\{${key}\\}\\}`, 'g');
    result = result.replace(regex, safeValue);
  }

  return result;
}

/**
 * Procesa un template de email obtenido de la base de datos
 * @param {string} templateHTML - Template HTML de la BD
 * @param {object} data - Datos para el template
 * @returns {string} HTML procesado y listo para enviar
 *
 * @example
 * // En workflow después de obtener template de DB:
 * const template = $json.html_template;
 * const emailHTML = processEmailTemplate(template, {
 *   nombre: usuario.nombre,
 *   sesion_numero: 1,
 *   sesiones_total: 3,
 *   titulo: 'Semana 1: Despertando el cuerpo',
 *   // ... más variables
 * });
 */
function processEmailTemplate(templateHTML, data) {
  console.log('📧 Procesando template de email...');
  console.log(`📊 Variables a reemplazar: ${Object.keys(data).join(', ')}`);

  const result = replaceVariables(templateHTML, data);

  // Verificar si quedan variables sin reemplazar
  const unreplacedVars = result.match(/\{\{[^}]+\}\}/g);
  if (unreplacedVars) {
    console.warn(`⚠️ Variables sin reemplazar encontradas: ${unreplacedVars.join(', ')}`);
  } else {
    console.log('✅ Todas las variables reemplazadas correctamente');
  }

  return result;
}

/**
 * EJEMPLO DE USO EN WORKFLOW N8N
 * ===============================
 *
 * Nodo 1: PostgreSQL - Obtener Template
 * -------------------------------------
 * Query:
 * ```sql
 * SET search_path TO camino_vital;
 * SELECT * FROM get_email_template('sesion_ejercicios');
 * ```
 *
 * Nodo 2: Code - Procesar Template
 * --------------------------------
 * ```javascript
 * // Copiar las funciones replaceVariables y processEmailTemplate aquí
 *
 * // Obtener template de DB
 * const template = $input.first().json.html_template;
 *
 * // Preparar variables
 * const variables = {
 *   titulo: contenido.titulo,
 *   descripcion: contenido.descripcion,
 *   duracion: contenido.duracion_estimada,
 *   enfoque: contenido.enfoque,
 *   ejercicios_html: ejerciciosHTML,
 *   sesion_numero: 1,
 *   sesiones_total: usuario.sesiones_objetivo_semana,
 *   semana_numero: usuario.semana_actual,
 *   user_id: usuario.id,
 *   webhook_url: 'https://n8n.habitos-vitales.com/webhook'
 * };
 *
 * // Procesar template
 * const emailHTML = processEmailTemplate(template, variables);
 *
 * return {
 *   json: {
 *     user_email: usuario.email,
 *     user_nombre: usuario.nombre,
 *     email_html: emailHTML,
 *     asunto: `🎯 Sesión ${variables.sesion_numero} de ${variables.sesiones_total}`
 *   }
 * };
 * ```
 *
 * Nodo 3: HTTP Request - Enviar Email
 * -----------------------------------
 * Usar {{ $json.email_html }} como contenido
 */

// Exportar funciones (para uso en módulos)
if (typeof module !== 'undefined' && module.exports) {
  module.exports = {
    replaceVariables,
    processEmailTemplate
  };
}
