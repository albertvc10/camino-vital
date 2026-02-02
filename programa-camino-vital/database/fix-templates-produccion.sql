UPDATE email_templates SET html_template = '<!DOCTYPE html><html lang="es"><head><meta charset="UTF-8"><meta name="viewport" content="width=device-width, initial-scale=1.0"><title>{{titulo}} - Camino Vital</title><style>*{margin:0;padding:0;box-sizing:border-box}body{font-family:-apple-system,BlinkMacSystemFont,"Segoe UI",Roboto,sans-serif;background:linear-gradient(180deg,#232323 0%,#1C1C1C 100%);min-height:100vh;display:flex;align-items:center;justify-content:center;padding:20px}.card{background:#1C1C1C;border-radius:18px;padding:50px 40px;box-shadow:0 10px 40px rgba(0,0,0,0.4);border:1px solid rgba(255,255,255,0.08);text-align:center;max-width:500px;width:100%}.icon{font-size:64px;margin-bottom:25px}h1{color:#62B882;margin:0 0 20px 0;font-size:28px}p{font-size:16px;line-height:1.7;color:#B5B5B5;margin-bottom:15px}.highlight{color:#DFCA61;font-weight:600}.btn{display:inline-block;background:#DFCA61;color:#1C1C1C;padding:16px 32px;border-radius:12px;text-decoration:none;font-weight:600;margin-top:25px;transition:all 0.3s ease}.btn:hover{transform:translateY(-2px);box-shadow:0 6px 20px rgba(223,202,97,0.3)}.footer{margin-top:30px;padding-top:20px;border-top:1px solid rgba(255,255,255,0.08);color:#666;font-size:13px}</style></head><body><div class="card"><div style="margin-bottom:20px"><img src="https://habitos-vitales.com/wp-content/uploads/2023/09/1-e1769547181637.png" alt="Hábitos Vitales" style="max-width:120px;height:auto"></div><div class="icon">{{icono}}</div><h1>{{titulo}}</h1><p>{{mensaje}}</p>{{#if mensaje_secundario}}<p>{{mensaje_secundario}}</p>{{/if}}{{#if boton_texto}}<a href="{{boton_url}}" class="btn">{{boton_texto}}</a>{{/if}}<div class="footer"><strong style="color:#DFCA61">Camino Vital</strong> | Hábitos Vitales</div></div></body></html>' WHERE nombre = 'pagina_confirmacion';
UPDATE email_templates SET html_template = '<!DOCTYPE html><html lang="es"><head><meta charset="UTF-8"><meta name="viewport" content="width=device-width, initial-scale=1.0"><title>{{titulo}} - Camino Vital</title><style>*{margin:0;padding:0;box-sizing:border-box}body{font-family:-apple-system,BlinkMacSystemFont,"Segoe UI",Roboto,sans-serif;background:linear-gradient(180deg,#232323 0%,#1C1C1C 100%);min-height:100vh;display:flex;align-items:center;justify-content:center;padding:20px}.card{background:#1C1C1C;border-radius:18px;padding:50px 40px;box-shadow:0 10px 40px rgba(0,0,0,0.4);border:1px solid rgba(255,255,255,0.08);text-align:center;max-width:500px;width:100%}.icon{font-size:64px;margin-bottom:25px}h1{color:#E74C3C;margin:0 0 20px 0;font-size:28px}p{font-size:16px;line-height:1.7;color:#B5B5B5;margin-bottom:15px}a{color:#DFCA61;text-decoration:none;font-weight:600}a:hover{text-decoration:underline}.footer{margin-top:30px;padding-top:20px;border-top:1px solid rgba(255,255,255,0.08);color:#666;font-size:13px}</style></head><body><div class="card"><div style="margin-bottom:20px"><img src="https://habitos-vitales.com/wp-content/uploads/2023/09/1-e1769547181637.png" alt="Hábitos Vitales" style="max-width:120px;height:auto"></div><div class="icon">{{icono}}</div><h1>{{titulo}}</h1><p>{{mensaje}}</p>{{#if contacto}}<p style="margin-top:20px">Si necesitas ayuda:<br><a href="mailto:hola@habitos-vitales.com">hola@habitos-vitales.com</a></p>{{/if}}<div class="footer"><strong style="color:#DFCA61">Camino Vital</strong> | Hábitos Vitales</div></div></body></html>' WHERE nombre = 'pagina_error';
UPDATE email_templates SET html_template = '<!DOCTYPE html><html><head><meta charset="UTF-8"><meta name="viewport" content="width=device-width, initial-scale=1.0"><title>¡Nueva semana!</title><style>:root{--color-primary:#DFCA61;--color-success:#62B882;--color-bg-dark:#232323;--color-bg-card:#1C1C1C;--color-text-primary:#E8E8E8;--color-text-secondary:#B5B5B5;--border-radius-card:18px}*{box-sizing:border-box;margin:0;padding:0}body{font-family:-apple-system,BlinkMacSystemFont,"Segoe UI",Roboto,sans-serif;background:var(--color-bg-dark);min-height:100vh;display:flex;align-items:center;justify-content:center;padding:20px}.card{background:var(--color-bg-card);border-radius:var(--border-radius-card);padding:48px 40px;max-width:480px;width:100%;text-align:center;border:1px solid rgba(255,255,255,0.08)}.icon{font-size:64px;margin-bottom:24px}h1{color:var(--color-success);font-size:28px;font-weight:700;margin-bottom:16px}.highlight{background:rgba(98,184,130,0.1);border:1px solid rgba(98,184,130,0.3);border-radius:12px;padding:24px;margin:24px 0}.semana{font-size:48px;font-weight:700;color:var(--color-success)}.sesiones{color:var(--color-text-secondary);font-size:14px;margin-top:8px}.processing{background:rgba(223,202,97,0.1);border:1px solid rgba(223,202,97,0.3);border-radius:12px;padding:16px 20px;margin:24px 0}.loader-container{display:flex;align-items:center;justify-content:center;gap:10px;margin-bottom:8px}.loader{width:16px;height:16px;border:2px solid rgba(223,202,97,0.3);border-top-color:var(--color-primary);border-radius:50%;animation:spin 1s linear infinite}@keyframes spin{to{transform:rotate(360deg)}}.processing-text{color:var(--color-primary);font-size:14px}.processing-note{color:var(--color-text-secondary);font-size:13px}.text-primary{color:var(--color-text-primary);font-size:16px;margin:24px 0}.signature{color:var(--color-text-secondary);font-size:14px}.signature strong{color:var(--color-success)}</style></head><body><div class="card"><div style="margin-bottom:20px"><img src="https://habitos-vitales.com/wp-content/uploads/2023/09/1-e1769547181637.png" alt="Hábitos Vitales" style="max-width:120px;height:auto"></div><div class="icon">🚀</div><h1>¡Comienza la semana {{semana_actual}}!</h1><div class="highlight"><div class="semana">Semana {{semana_actual}}</div><div class="sesiones">{{sesiones_objetivo_semana}} sesiones programadas</div></div><div class="processing"><div class="loader-container"><div class="loader"></div><span class="processing-text">Preparando tu primera sesión...</span></div><p class="processing-note">📧 Te enviaremos un email en breve.</p></div><p class="text-primary">¡A por ello! 💪</p><div class="signature"><strong>El equipo de Camino Vital</strong></div></div></body></html>' WHERE nombre = 'pagina_nueva_semana';
UPDATE email_templates SET html_template = '<!DOCTYPE html><html><head><meta charset="UTF-8"><meta name="viewport" content="width=device-width, initial-scale=1.0"><title>¡Perfecto!</title><style>:root{--color-primary:#DFCA61;--color-success:#62B882;--color-purple:#667eea;--color-bg-dark:#232323;--color-bg-card:#1C1C1C;--color-text-primary:#E8E8E8;--color-text-secondary:#B5B5B5;--border-radius-card:18px}*{box-sizing:border-box;margin:0;padding:0}body{font-family:-apple-system,BlinkMacSystemFont,"Segoe UI",Roboto,sans-serif;background:var(--color-bg-dark);min-height:100vh;display:flex;align-items:center;justify-content:center;padding:20px}.card{background:var(--color-bg-card);border-radius:var(--border-radius-card);padding:48px 40px;max-width:480px;width:100%;text-align:center;border:1px solid rgba(255,255,255,0.08)}.icon{font-size:64px;margin-bottom:24px}h1{color:var(--color-success);font-size:28px;font-weight:700;margin-bottom:16px}.text-primary{color:var(--color-text-primary);font-size:18px;margin:16px 0}.highlight{background:rgba(98,184,130,0.1);border:1px solid rgba(98,184,130,0.3);border-radius:12px;padding:24px;margin:24px 0}.highlight p{color:var(--color-text-secondary);font-size:16px;margin:8px 0}.highlight strong{color:var(--color-success)}.loader{display:inline-block;width:20px;height:20px;border:3px solid var(--color-success);border-radius:50%;border-top-color:transparent;animation:spin 1s linear infinite;margin-right:10px;vertical-align:middle}@keyframes spin{to{transform:rotate(360deg)}}.signature{margin-top:32px;color:var(--color-text-secondary);font-size:14px}</style></head><body><div class="card"><div style="margin-bottom:20px"><img src="https://habitos-vitales.com/wp-content/uploads/2023/09/1-e1769547181637.png" alt="Hábitos Vitales" style="max-width:120px;height:auto"></div><div class="icon">🎉</div><h1>¡Perfecto!</h1><p class="text-primary">Has elegido hacer <strong>{{sesiones_objetivo_semana}} sesiones esta semana</strong></p><div class="highlight"><p><span class="loader"></span>Estamos preparando tu primera sesión personalizada...</p><p>📧 <strong>Recibirás un email en 1-2 minutos</strong></p></div><p class="signature">Puedes cerrar esta ventana.<br>Tu sesión llegará a tu correo muy pronto.</p><p class="signature" style="margin-top:16px">¡Bienvenido a Camino Vital! 💪</p></div></body></html>' WHERE nombre = 'pagina_procesando_primera';
UPDATE email_templates SET html_template = '<!DOCTYPE html><html><head><meta charset="UTF-8"><meta name="viewport" content="width=device-width, initial-scale=1.0"><title>¡Genial!</title><style>:root{--color-primary:#DFCA61;--color-success:#62B882;--color-bg-dark:#232323;--color-bg-card:#1C1C1C;--color-text-primary:#E8E8E8;--color-text-secondary:#B5B5B5;--border-radius-card:18px}*{box-sizing:border-box;margin:0;padding:0}body{font-family:-apple-system,BlinkMacSystemFont,"Segoe UI",Roboto,sans-serif;background:var(--color-bg-dark);min-height:100vh;display:flex;align-items:center;justify-content:center;padding:20px}.card{background:var(--color-bg-card);border-radius:var(--border-radius-card);padding:48px 40px;max-width:480px;width:100%;text-align:center;border:1px solid rgba(255,255,255,0.08)}.icon{font-size:64px;margin-bottom:24px}h1{color:var(--color-success);font-size:28px;font-weight:700;margin-bottom:16px}.text-primary{color:var(--color-text-primary);font-size:18px;margin:16px 0}.highlight{background:rgba(98,184,130,0.1);border:1px solid rgba(98,184,130,0.3);border-radius:12px;padding:24px;margin:24px 0}.highlight p{color:var(--color-text-secondary);font-size:16px;margin:8px 0}.highlight strong{color:var(--color-success)}.loader{display:inline-block;width:20px;height:20px;border:3px solid var(--color-success);border-radius:50%;border-top-color:transparent;animation:spin 1s linear infinite;margin-right:10px;vertical-align:middle}@keyframes spin{to{transform:rotate(360deg)}}.signature{margin-top:32px;color:var(--color-text-secondary);font-size:14px}</style></head><body><div class="card"><div style="margin-bottom:20px"><img src="https://habitos-vitales.com/wp-content/uploads/2023/09/1-e1769547181637.png" alt="Hábitos Vitales" style="max-width:120px;height:auto"></div><div class="icon">✅</div><h1>¡Feedback recibido!</h1><p class="text-primary">Gracias por completar la sesión {{sesion_completada}}</p><div class="highlight"><p><span class="loader"></span>Preparando tu siguiente sesión...</p><p>📧 <strong>Recibirás un email en 1-2 minutos</strong></p></div><p class="signature">Puedes cerrar esta ventana.<br>Tu próxima sesión llegará a tu correo.</p></div></body></html>' WHERE nombre = 'pagina_procesando_siguiente';
UPDATE email_templates SET html_template = '<!DOCTYPE html><html><head><meta charset="UTF-8"><meta name="viewport" content="width=device-width, initial-scale=1.0"><title>¡Programa Completado!</title><style>:root{--color-primary:#DFCA61;--color-success:#62B882;--color-bg-dark:#232323;--color-bg-card:#1C1C1C;--color-text-primary:#E8E8E8;--color-text-secondary:#B5B5B5;--border-radius-card:18px}*{box-sizing:border-box;margin:0;padding:0}body{font-family:-apple-system,BlinkMacSystemFont,"Segoe UI",Roboto,sans-serif;background:var(--color-bg-dark);min-height:100vh;display:flex;align-items:center;justify-content:center;padding:20px}.card{background:var(--color-bg-card);border-radius:var(--border-radius-card);padding:48px 40px;max-width:520px;width:100%;text-align:center;border:1px solid rgba(255,255,255,0.08)}.icon{font-size:100px;margin-bottom:24px}h1{color:var(--color-primary);font-size:32px;font-weight:700;margin-bottom:16px}.subtitle{color:var(--color-text-primary);font-size:18px;margin-bottom:32px}.stats{display:flex;justify-content:center;gap:24px;margin:32px 0}.stat{background:rgba(223,202,97,0.1);border:1px solid rgba(223,202,97,0.3);border-radius:12px;padding:20px 32px}.stat-number{font-size:36px;font-weight:700;color:var(--color-primary)}.stat-label{font-size:13px;color:var(--color-text-secondary);margin-top:4px}.message{background:rgba(98,184,130,0.1);border:1px solid rgba(98,184,130,0.3);border-radius:12px;padding:20px;margin:32px 0}.message p{color:var(--color-success);font-size:15px}.text-primary{color:var(--color-text-primary);font-size:16px;margin:16px 0}.signature{margin-top:32px;font-size:16px}.signature .thanks{color:var(--color-text-primary)}.signature strong{color:var(--color-primary)}</style></head><body><div class="card"><div style="margin-bottom:20px"><img src="https://habitos-vitales.com/wp-content/uploads/2023/09/1-e1769547181637.png" alt="Hábitos Vitales" style="max-width:120px;height:auto"></div><div class="icon">🏆</div><h1>¡Felicidades!</h1><p class="subtitle">Has completado <strong>Base Vital</strong></p><div class="stats"><div class="stat"><div class="stat-number">12</div><div class="stat-label">Semanas</div></div></div><div class="message"><p>✅ Has demostrado constancia y compromiso. ¡Sigue moviéndote!</p></div><p class="text-primary">Has creado hábitos que te acompañarán toda la vida. 💛</p><div class="signature"><p class="thanks">Gracias por confiar en nosotros</p><p><strong>El equipo de Camino Vital</strong></p></div></div></body></html>' WHERE nombre = 'pagina_programa_completado';
UPDATE email_templates SET html_template = '<!DOCTYPE html><html><head><meta charset="UTF-8"><meta name="viewport" content="width=device-width, initial-scale=1.0"><title>¡Semana completada!</title><style>:root{--color-primary:#DFCA61;--color-success:#62B882;--color-bg-dark:#232323;--color-bg-card:#1C1C1C;--color-text-primary:#E8E8E8;--color-text-secondary:#B5B5B5;--border-radius-card:18px}*{box-sizing:border-box;margin:0;padding:0}body{font-family:-apple-system,BlinkMacSystemFont,"Segoe UI",Roboto,sans-serif;background:var(--color-bg-dark);min-height:100vh;display:flex;align-items:center;justify-content:center;padding:20px}.card{background:var(--color-bg-card);border-radius:var(--border-radius-card);padding:48px 40px;max-width:480px;width:100%;text-align:center;border:1px solid rgba(255,255,255,0.08)}.icon{font-size:80px;margin-bottom:24px}h1{color:var(--color-primary);font-size:28px;font-weight:700;margin-bottom:16px}.highlight{background:rgba(223,202,97,0.1);border:1px solid rgba(223,202,97,0.3);border-radius:12px;padding:24px;margin:24px 0}.highlight p{color:var(--color-primary);font-size:18px;font-weight:600}.info{background:rgba(98,184,130,0.1);border:1px solid rgba(98,184,130,0.3);border-radius:12px;padding:16px 20px;margin:24px 0}.info p{color:var(--color-success);font-size:14px}.text-primary{color:var(--color-text-primary);font-size:16px;margin:16px 0}.signature{margin-top:32px;color:var(--color-text-secondary);font-size:14px}.signature strong{color:var(--color-primary)}</style></head><body><div class="card"><div style="margin-bottom:20px"><img src="https://habitos-vitales.com/wp-content/uploads/2023/09/1-e1769547181637.png" alt="Hábitos Vitales" style="max-width:120px;height:auto"></div><div class="icon">🎉</div><h1>¡Semana {{semana_actual}} completada!</h1><div class="highlight"><p>Has completado las {{sesiones_objetivo_semana}} sesiones</p></div><div class="info"><p>📊 El domingo recibirás tu checkpoint semanal.</p></div><p class="text-primary">¡Increíble constancia! 💪</p><div class="signature"><strong>El equipo de Camino Vital</strong></div></div></body></html>' WHERE nombre = 'pagina_semana_completada';
UPDATE email_templates SET html_template = '<!DOCTYPE html>
<html lang="es">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>{{titulo}} - Camino Vital</title>
  <style>
    {{css_base}}
    
    /* Estilos específicos de sesión */
    .ejercicio {
      background: rgba(255,255,255,0.04);
      border: 1px solid rgba(255,255,255,0.08);
      border-radius: 18px;
      padding: 25px;
      margin-bottom: 25px;
    }
    
    .ejercicio-calentamiento {
      border-left: 4px solid #62B882;
    }
    
    .ejercicio-principal {
      border-left: 4px solid #DFCA61;
    }
    
    .ejercicio-header {
      display: flex;
      align-items: center;
      margin-bottom: 15px;
    }
    
    .ejercicio-numero {
      width: 40px;
      height: 40px;
      border-radius: 50%;
      display: flex;
      align-items: center;
      justify-content: center;
      font-weight: bold;
      font-size: 16px;
      margin-right: 15px;
    }
    
    .ejercicio-numero-calentamiento {
      background: #62B882;
      color: #FFFFFF;
    }
    
    .ejercicio-numero-principal {
      background: #DFCA61;
      color: #1C1C1C;
    }
    
    .ejercicio h3 {
      margin: 0;
      color: #FFFFFF;
      font-size: 18px;
      flex: 1;
    }
    
    .video-container {
      position: relative;
      width: 70%;
      max-width: 320px;
      margin: 0 auto 15px auto;
      padding-bottom: 75%;
      background: #000;
      border-radius: 12px;
      overflow: hidden;
      border: 1px solid rgba(255,255,255,0.1);
    }
    
    .video-container video {
      position: absolute;
      top: 0;
      left: 0;
      width: 100%;
      height: 100%;
      object-fit: contain;
    }
    
    .ejercicio-detalles {
      background: rgba(255,255,255,0.04);
      padding: 15px;
      border-radius: 12px;
      border: 1px solid rgba(255,255,255,0.05);
    }
    
    .ejercicio-detalles div {
      margin-bottom: 8px;
      color: #B5B5B5;
    }
    
    .ejercicio-detalles strong {
      color: #DFCA61;
    }
    
    .ejercicio-consejo {
      background: rgba(223, 202, 97, 0.1);
      padding: 12px;
      border-radius: 8px;
      border-left: 3px solid #DFCA61;
      margin-top: 10px;
      color: #DFCA61;
    }
    
    .introduccion {
      background: rgba(98, 184, 130, 0.1);
      border-left: 4px solid #62B882;
      padding: 25px;
      border-radius: 12px;
      margin-bottom: 30px;
      line-height: 1.8;
      color: #d6d6d6;
    }
    
    .introduccion strong {
      color: #62B882;
      display: block;
      margin-bottom: 12px;
      font-size: 18px;
    }
    
    .feedback-container {
      background: rgba(255,255,255,0.04);
      padding: 30px;
      border-radius: 18px;
      margin: 40px 0;
      border: 1px solid rgba(255,255,255,0.08);
    }
    
    .feedback-container h3 {
      text-align: center;
      margin: 0 0 10px 0;
      color: #FFFFFF;
      font-size: 22px;
    }
    
    .feedback-obligatorio {
      text-align: center;
      color: #DFCA61;
      font-size: 14px;
      margin: 0 0 25px 0;
      line-height: 1.5;
      padding: 12px;
      background: rgba(223, 202, 97, 0.1);
      border-radius: 8px;
    }
    
    .feedback-btn {
      display: block;
      width: 100%;
      padding: 18px;
      margin: 12px 0;
      border-radius: 12px;
      text-decoration: none;
      text-align: center;
      font-size: 16px;
      font-weight: 600;
      transition: all 0.3s ease;
      color: #FFFFFF;
    }
    
    .feedback-btn.facil {
      background: #62B882;
    }
    
    .feedback-btn.bien {
      background: #DFCA61;
      color: #1C1C1C;
    }
    
    .feedback-btn.dificil {
      background: #E67E22;
    }
    
    .feedback-btn:hover {
      transform: translateY(-2px);
      box-shadow: 0 6px 20px rgba(0,0,0,0.3);
    }
    
    .separador {
      border-top: 1px solid rgba(255,255,255,0.1);
      margin: 20px 0;
    }
    
    .contacto-ayuda {
      text-align: center;
      padding: 15px;
      color: #888;
      font-size: 14px;
      line-height: 1.6;
    }
    
    .contacto-ayuda a {
      color: #DFCA61;
      text-decoration: none;
      font-weight: 600;
    }
    
    .contacto-ayuda a:hover {
      text-decoration: underline;
    }
  </style>
</head>
<body>
  <div class="hv-container">
    <div class="hv-header">
      <img src="https://habitos-vitales.com/wp-content/uploads/2023/09/1-e1769547181637.png" alt="Hábitos Vitales" style="max-width: 150px; height: auto; margin-bottom: 15px;">
      <h1>{{titulo}}</h1>
      <p style="color: #B5B5B5; margin-top: 10px; font-size: 18px;">Hola {{user_nombre}}, ¡es hora de moverte!</p>
      
      <div class="hv-header-meta">
        <div class="hv-meta-item">⏱️ {{duracion_estimada}}</div>
        <div class="hv-meta-item">📊 Nivel {{nivel_actual}}</div>
        <div class="hv-meta-item">🎯 {{enfoque}}</div>
        <div class="hv-meta-item">📅 Semana {{semana_actual}} · Sesión {{numero_sesion}} de {{sesiones_objetivo}}</div>
      </div>
    </div>
    
    <div class="hv-content">
      <div class="introduccion">
        <strong>✨ Tu sesión personalizada</strong>
        {{introduccion_personalizada}}
      </div>
      
      <h2 class="hv-section-title">🔥 Calentamiento</h2>
      <p style="color: #B5B5B5; margin-bottom: 25px;">
        Prepara tu cuerpo con estos ejercicios suaves. Ve a tu ritmo y respira profundamente.
      </p>
      {{html_calentamiento}}
      
      <h2 class="hv-section-title">💪 Trabajo Principal</h2>
      <p style="color: #B5B5B5; margin-bottom: 25px;">
        Estos son los ejercicios principales de hoy. Recuerda: calidad sobre cantidad.
      </p>
      {{html_trabajo_principal}}
      
      <div class="feedback-container">
        <h3>Completa tu sesión</h3>
        <p class="feedback-obligatorio">
          ⚠️ <strong>Paso obligatorio</strong> — Selecciona cómo te fue para marcar esta sesión como completada y recibir la siguiente.
        </p>
        
        <a href="{{webhook_url}}/webhook/sesion-completada?user_id={{user_id}}&sesion={{numero_sesion}}&feedback=completa_facil" class="feedback-btn facil">
          😊 Fácil - Podría haber hecho más<span style="display:block;font-size:13px;font-weight:normal;margin-top:4px;opacity:0.85;">Completar y recibir siguiente →</span>
        </a>
        
        <a href="{{webhook_url}}/webhook/sesion-completada?user_id={{user_id}}&sesion={{numero_sesion}}&feedback=completa_bien" class="feedback-btn bien">
          💪 Apropiado - Nivel perfecto<span style="display:block;font-size:13px;font-weight:normal;margin-top:4px;opacity:0.85;">Completar y recibir siguiente →</span>
        </a>
        
        <a href="{{webhook_url}}/webhook/sesion-completada?user_id={{user_id}}&sesion={{numero_sesion}}&feedback=completa_dificil" class="feedback-btn dificil">
          😰 Difícil - Me costó pero lo logré<span style="display:block;font-size:13px;font-weight:normal;margin-top:4px;opacity:0.85;">Completar y recibir siguiente →</span>
        </a>
        
        <div class="separador"></div>
        
        <div class="contacto-ayuda">
          <p><strong>¿Tuviste dificultades o molestias?</strong></p>
          <p>Tu bienestar es lo primero. Si algo no fue bien o tienes una lesión que debamos conocer, escríbenos a <a href="mailto:hola@habitos-vitales.com">hola@habitos-vitales.com</a> y adaptaremos tu programa.</p>
        </div>
      </div>
    </div>
    
    <div class="hv-footer">
      <p><strong style="color: #DFCA61;">Camino Vital</strong> | Hábitos Vitales</p>
      <p style="margin-top: 10px;">Programa personalizado de ejercicio</p>
    </div>
  </div>
  
  <script>
    // Auto-pause de videos cuando no están visibles
    const videos = document.querySelectorAll("video");
    const observer = new IntersectionObserver((entries) => {
      entries.forEach(entry => {
        if (!entry.isIntersecting) {
          entry.target.pause();
        }
      });
    }, { threshold: 0.5 });
    videos.forEach(video => observer.observe(video));
  </script>
</body>
</html>' WHERE nombre = 'pagina_sesion';
UPDATE email_templates SET html_template = '<!DOCTYPE html><html><head><meta charset="UTF-8"><meta name="viewport" content="width=device-width, initial-scale=1.0"><title>¡Sesión completada!</title><style>:root{--color-primary:#DFCA61;--color-success:#62B882;--color-bg-dark:#232323;--color-bg-card:#1C1C1C;--color-text-primary:#E8E8E8;--color-text-secondary:#B5B5B5;--border-radius-card:18px}*{box-sizing:border-box;margin:0;padding:0}body{font-family:-apple-system,BlinkMacSystemFont,"Segoe UI",Roboto,sans-serif;background:var(--color-bg-dark);min-height:100vh;display:flex;align-items:center;justify-content:center;padding:20px}.card{background:var(--color-bg-card);border-radius:var(--border-radius-card);padding:48px 40px;max-width:480px;width:100%;text-align:center}.icon{font-size:64px;margin-bottom:24px}h1{color:var(--color-success);font-size:28px;font-weight:700;margin-bottom:16px}.highlight{background:rgba(98,184,130,0.1);border:1px solid rgba(98,184,130,0.3);border-radius:12px;padding:20px;margin:24px 0}.highlight p{color:var(--color-success);font-size:16px;font-weight:600}.info{background:rgba(223,202,97,0.1);border:1px solid rgba(223,202,97,0.3);border-radius:12px;padding:16px 20px;margin:24px 0}.info p{color:var(--color-primary);font-size:14px}.loader-container{display:flex;align-items:center;justify-content:center;gap:12px;margin:24px 0}.loader{width:20px;height:20px;border:3px solid rgba(98,184,130,0.3);border-top-color:var(--color-success);border-radius:50%;animation:spin 1s linear infinite}@keyframes spin{to{transform:rotate(360deg)}}.loader-text{color:var(--color-text-primary);font-size:16px}.note{color:var(--color-text-secondary);font-size:14px}</style></head><body><div class="card"><div style="margin-bottom: 20px;"><img src="https://habitos-vitales.com/wp-content/uploads/2023/09/1-e1769547181637.png" alt="Hábitos Vitales" style="max-width: 120px; height: auto;"></div><div class="icon">💪</div><h1>¡Sesión completada!</h1><div class="highlight"><p>Sesión {{sesion_numero}} de {{sesiones_objetivo_semana}} esta semana</p></div><div class="info"><p>📊 Tu feedback cuenta: ajustaremos tu próxima semana.</p></div><div class="loader-container"><div class="loader"></div><span class="loader-text">Preparando siguiente sesión...</span></div><p class="note">Te enviaremos un email en breve.</p></div></body></html>' WHERE nombre = 'pagina_sesion_completada';
UPDATE email_templates SET html_template = '<!DOCTYPE html><html><head><meta charset="UTF-8"><meta name="viewport" content="width=device-width, initial-scale=1.0"><title>Sesión ya procesada</title><style>:root{--color-info:#5DA9E9;--color-bg-dark:#232323;--color-bg-card:#1C1C1C;--color-text-primary:#E8E8E8;--color-text-secondary:#B5B5B5;--color-accent:#DFCA61;--border-radius-card:18px}*{box-sizing:border-box;margin:0;padding:0}body{font-family:-apple-system,BlinkMacSystemFont,"Segoe UI",Roboto,sans-serif;background:var(--color-bg-dark);min-height:100vh;display:flex;align-items:center;justify-content:center;padding:20px}.card{background:var(--color-bg-card);border-radius:var(--border-radius-card);padding:48px 40px;max-width:480px;width:100%;text-align:center;border:1px solid rgba(255,255,255,0.08)}.icon{font-size:64px;margin-bottom:24px}h1{color:var(--color-info);font-size:24px;font-weight:700;margin-bottom:16px}.info{background:rgba(93,169,233,0.1);border:1px solid rgba(93,169,233,0.3);border-radius:12px;padding:20px;margin:24px 0}.info p{color:var(--color-text-secondary);font-size:15px;line-height:1.6;margin:0}.text-primary{color:var(--color-text-primary);font-size:16px;margin-bottom:20px}.contact{background:rgba(223,202,97,0.1);border:1px solid rgba(223,202,97,0.3);border-radius:12px;padding:16px;margin-top:24px}.contact p{color:var(--color-text-secondary);font-size:14px;margin:0}.contact a{color:var(--color-accent);text-decoration:none;font-weight:600}.signature{margin-top:32px;color:var(--color-text-secondary);font-size:14px}</style></head><body><div class="card"><div style="margin-bottom:20px"><img src="https://habitos-vitales.com/wp-content/uploads/2023/09/1-e1769547181637.png" alt="Hábitos Vitales" style="max-width:120px;height:auto"></div><div class="icon">✅</div><h1>Esta sesión ya fue procesada</h1><div class="info"><p>Ya registramos tu feedback para esta sesión y te enviamos la siguiente.</p></div><p class="text-primary">Revisa tu bandeja de entrada (y spam) para encontrar tu próxima sesión.</p><div class="contact"><p>¿No recibiste el email? Escríbenos a<br><a href="mailto:hola@habitos-vitales.com">hola@habitos-vitales.com</a></p></div><div class="signature">El equipo de Camino Vital</div></div></body></html>' WHERE nombre = 'pagina_sesion_ya_procesada';
UPDATE email_templates SET html_template = '<!DOCTYPE html><html><head><meta charset="UTF-8"><meta name="viewport" content="width=device-width, initial-scale=1.0"><title>Ya configurado</title><style>:root{--color-info:#5DA9E9;--color-bg-dark:#232323;--color-bg-card:#1C1C1C;--color-text-primary:#E8E8E8;--color-text-secondary:#B5B5B5;--border-radius-card:18px}*{box-sizing:border-box;margin:0;padding:0}body{font-family:-apple-system,BlinkMacSystemFont,"Segoe UI",Roboto,sans-serif;background:var(--color-bg-dark);min-height:100vh;display:flex;align-items:center;justify-content:center;padding:20px}.card{background:var(--color-bg-card);border-radius:var(--border-radius-card);padding:48px 40px;max-width:480px;width:100%;text-align:center;border:1px solid rgba(255,255,255,0.08)}.icon{font-size:64px;margin-bottom:24px}h1{color:var(--color-info);font-size:28px;font-weight:700;margin-bottom:16px}.info{background:rgba(93,169,233,0.1);border:1px solid rgba(93,169,233,0.3);border-radius:12px;padding:20px;margin:24px 0}.info p{color:var(--color-info);font-size:15px}.text-primary{color:var(--color-text-primary);font-size:16px}.signature{margin-top:32px;color:var(--color-text-secondary);font-size:14px}</style></head><body><div class="card"><div style="margin-bottom:20px"><img src="https://habitos-vitales.com/wp-content/uploads/2023/09/1-e1769547181637.png" alt="Hábitos Vitales" style="max-width:120px;height:auto"></div><div class="icon">✅</div><h1>Ya tienes las sesiones configuradas</h1><div class="info"><p>Tu programa de esta semana ya fue configurado anteriormente.</p></div><p class="text-primary">Revisa tu email para ver tu próxima sesión.</p><div class="signature">El equipo de Camino Vital</div></div></body></html>' WHERE nombre = 'pagina_ya_configurado';
