-- ============================================
-- TEMPLATE: Página de Sesión Moderna V2
-- ============================================
-- Fecha: Febrero 2026
-- Propósito: Nueva experiencia de sesión con vista única de video/fase
-- Características:
--   - Vista de un ejercicio/fase a la vez (no scroll)
--   - Navegación entre ejercicios con botones
--   - Timer que inicia con el primer video
--   - Soporte para Fuerza (videos) y Cardio (fases/timer)
--   - Feedback integrado al final
-- ============================================

-- Primero actualizamos el template existente o creamos uno nuevo
INSERT INTO email_templates (
  nombre,
  tipo,
  descripcion,
  html_template,
  variables_requeridas,
  version,
  activo
)
VALUES (
  'pagina_sesion_v2',
  'pagina',
  'Página de sesión moderna con vista única de ejercicio y navegación',
  '<!DOCTYPE html>
<html lang="es">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>{{titulo}} - Camino Vital</title>
  <link rel="preconnect" href="https://fonts.googleapis.com">
  <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
  <link href="https://fonts.googleapis.com/css2?family=DM+Sans:wght@400;500;600;700&display=swap" rel="stylesheet">
  <style>
    /* ============================================
       CSS Variables - Tema Hábitos Vitales
       ============================================ */
    :root {
      --hv-bg-primary: #1C1C1C;
      --hv-bg-secondary: #232323;
      --hv-bg-card: #2a2a2a;
      --hv-accent-gold: #DFCA61;
      --hv-accent-green: #22C55E;
      --hv-accent-green-dark: #16A34A;
      --hv-accent-red: #EF4444;
      --hv-text-primary: #E8E8E8;
      --hv-text-secondary: #B5B5B5;
      --hv-text-muted: #888888;
      --hv-text-dim: #666666;
      --hv-border: #333333;
      --hv-border-subtle: rgba(255,255,255,0.08);
    }

    /* ============================================
       Reset y Base
       ============================================ */
    * {
      margin: 0;
      padding: 0;
      box-sizing: border-box;
    }

    body {
      font-family: "DM Sans", system-ui, -apple-system, sans-serif;
      background: var(--hv-bg-primary);
      color: var(--hv-text-primary);
      min-height: 100vh;
      line-height: 1.5;
    }

    /* ============================================
       Layout Principal
       ============================================ */
    .app-container {
      display: flex;
      flex-direction: column;
      min-height: 100vh;
    }

    /* Header */
    .header {
      display: flex;
      justify-content: space-between;
      align-items: center;
      padding: 0 40px;
      height: 72px;
      background: var(--hv-bg-secondary);
      border-bottom: 1px solid var(--hv-border);
    }

    .logo {
      font-size: 18px;
      font-weight: 700;
      color: var(--hv-accent-gold);
    }

    /* Progress Section - Center */
    .progress-section {
      display: flex;
      flex-direction: column;
      align-items: center;
      gap: 8px;
      min-width: 320px;
    }

    .progress-top {
      display: flex;
      align-items: center;
      gap: 10px;
    }

    .progress-icon {
      font-size: 16px;
    }

    .progress-text {
      font-size: 14px;
      font-weight: 600;
      color: var(--hv-accent-green);
      transition: color 0.3s ease;
    }

    .progress-text.final {
      color: var(--hv-accent-gold);
    }

    /* Progress Bar Container */
    .progress-bar-container {
      width: 300px;
      height: 8px;
      background: var(--hv-border);
      border-radius: 4px;
      overflow: hidden;
      position: relative;
    }

    .progress-fill {
      height: 100%;
      background: linear-gradient(90deg, var(--hv-accent-green) 0%, #86EFAC 100%);
      border-radius: 4px;
      transition: width 0.5s ease, background 0.3s ease;
      position: relative;
    }

    .progress-fill.final {
      background: linear-gradient(90deg, var(--hv-accent-gold) 0%, #F59E0B 100%);
    }

    /* Progress bar glow animation */
    .progress-fill::after {
      content: "";
      position: absolute;
      top: 0;
      left: 0;
      right: 0;
      bottom: 0;
      background: linear-gradient(90deg, transparent 0%, rgba(255,255,255,0.3) 50%, transparent 100%);
      animation: progressShine 2s ease-in-out infinite;
    }

    @keyframes progressShine {
      0% { transform: translateX(-100%); }
      100% { transform: translateX(100%); }
    }

    /* Pulse animation for near completion */
    .progress-fill.pulse {
      animation: progressPulse 1.5s ease-in-out infinite;
    }

    @keyframes progressPulse {
      0%, 100% { filter: brightness(1); }
      50% { filter: brightness(1.3); }
    }


    /* Main Content */
    .main-content {
      flex: 1;
      display: flex;
      gap: 32px;
      padding: 32px 40px;
      max-width: 1400px;
      margin: 0 auto;
      width: 100%;
    }

    /* ============================================
       FUERZA: 3-Column Layout (Left Info | Center Video | Right Metrics)
       ============================================ */

    /* Left Column - Exercise Info */
    .left-column {
      width: 320px;
      flex-shrink: 0;
      display: flex;
      flex-direction: column;
      gap: 20px;
    }

    /* Center Column - Portrait Video */
    .center-column {
      flex: 1;
      display: flex;
      flex-direction: column;
      align-items: center;
      gap: 24px;
    }

    .video-container {
      position: relative;
      background: #0a0a0a;
      border-radius: 20px;
      overflow: hidden;
      width: 340px;
      height: 605px;
      border: 2px solid #333333;
    }

    .video-container video {
      width: 100%;
      height: 100%;
      object-fit: contain;
    }

    .video-placeholder {
      position: absolute;
      inset: 0;
      display: flex;
      align-items: center;
      justify-content: center;
      background: rgba(0,0,0,0.5);
      cursor: pointer;
    }

    .play-button {
      width: 80px;
      height: 80px;
      background: linear-gradient(135deg, #22C55E 0%, #16A34A 100%);
      border-radius: 50%;
      display: flex;
      align-items: center;
      justify-content: center;
      transition: all 0.2s;
    }

    .play-button:hover {
      transform: scale(1.1);
      filter: brightness(1.1);
    }

    .play-button svg {
      width: 32px;
      height: 32px;
      fill: white;
      margin-left: 4px;
    }

    /* Right Column - Metrics & Timer */
    .right-column {
      width: 280px;
      flex-shrink: 0;
      display: flex;
      flex-direction: column;
      gap: 20px;
    }

    /* Navigation Section - Separated dots and buttons */
    .nav-section {
      display: flex;
      flex-direction: column;
      align-items: center;
      gap: 16px;
      width: 100%;
    }

    /* Exercise Dots Row */
    .dots-row {
      display: flex;
      gap: 6px;
      align-items: center;
      justify-content: center;
    }

    .dot {
      width: 8px;
      height: 8px;
      border-radius: 4px;
      background: #444444;
      transition: all 0.3s ease;
      cursor: pointer;
    }

    .dot:hover {
      background: #555555;
    }

    .dot.completed {
      background: var(--hv-accent-green);
    }

    .dot.current {
      background: var(--hv-accent-gold);
      width: 20px;
    }

    /* Buttons Row */
    .buttons-row {
      display: flex;
      gap: 16px;
      align-items: center;
      justify-content: center;
    }

    .nav-btn {
      display: flex;
      align-items: center;
      gap: 8px;
      padding: 12px 24px;
      border-radius: 12px;
      font-size: 14px;
      font-weight: 500;
      cursor: pointer;
      transition: all 0.2s;
      border: none;
    }

    .nav-btn-prev {
      background: var(--hv-bg-card);
      color: var(--hv-text-secondary);
      border: 1px solid #404040;
    }

    .nav-btn-prev:hover:not(:disabled) {
      background: var(--hv-border);
    }

    .nav-btn-next {
      background: linear-gradient(135deg, var(--hv-accent-green) 0%, var(--hv-accent-green-dark) 100%);
      color: white;
      transition: all 0.3s ease;
    }

    .nav-btn-next.final {
      background: linear-gradient(135deg, var(--hv-accent-gold) 0%, #F59E0B 100%);
      padding: 16px 32px;
      font-size: 16px;
      font-weight: 700;
      animation: finalButtonPulse 1.5s ease-in-out infinite;
      box-shadow: 0 0 20px rgba(223, 202, 97, 0.4);
    }

    @keyframes finalButtonPulse {
      0%, 100% {
        transform: scale(1);
        box-shadow: 0 0 20px rgba(223, 202, 97, 0.4);
      }
      50% {
        transform: scale(1.05);
        box-shadow: 0 0 30px rgba(223, 202, 97, 0.6);
      }
    }

    .nav-btn-next:hover:not(:disabled) {
      filter: brightness(1.1);
      transform: translateY(-1px);
    }

    .nav-btn-next.final:hover {
      animation: none;
      transform: scale(1.08);
    }

    /* Final action message */
    .final-message {
      display: none;
      text-align: center;
      padding: 16px 24px;
      background: rgba(223, 202, 97, 0.1);
      border: 1px solid rgba(223, 202, 97, 0.3);
      border-radius: 12px;
      margin-top: 8px;
    }

    .final-message.visible {
      display: block;
      animation: fadeInUp 0.3s ease-out;
    }

    @keyframes fadeInUp {
      from { opacity: 0; transform: translateY(10px); }
      to { opacity: 1; transform: translateY(0); }
    }

    .final-message-text {
      font-size: 14px;
      color: var(--hv-accent-gold);
      font-weight: 500;
      margin: 0;
    }

    .final-message-subtext {
      font-size: 12px;
      color: var(--hv-text-muted);
      margin-top: 4px;
    }

    .nav-btn:disabled {
      opacity: 0.5;
      cursor: not-allowed;
    }

    /* Legacy nav-controls for backward compat */
    .nav-controls {
      display: none;
    }

    /* Timer Display */
    .timer-display {
      display: flex;
      align-items: center;
      gap: 12px;
      padding: 12px 20px;
      background: var(--hv-bg-secondary);
      border-radius: 12px;
    }

    .timer-icon {
      color: var(--hv-accent-gold);
    }

    .timer-text {
      font-size: 18px;
      font-weight: 600;
      color: var(--hv-text-primary);
      font-variant-numeric: tabular-nums;
    }

    .timer-label {
      font-size: 13px;
      color: var(--hv-text-muted);
    }

    /* ============================================
       Info Column (Detalles del Ejercicio)
       ============================================ */
    /* Metrics Card - List format */
    .metrics-card {
      background: var(--hv-bg-secondary);
      border-radius: 16px;
      padding: 20px;
    }

    .metrics-title {
      font-size: 11px;
      font-weight: 600;
      color: var(--hv-text-muted);
      text-transform: uppercase;
      letter-spacing: 0.5px;
      margin-bottom: 16px;
    }

    .metrics-list {
      display: flex;
      flex-direction: column;
      gap: 12px;
    }

    .metric-item {
      display: flex;
      align-items: flex-start;
      gap: 12px;
      padding: 12px;
      background: var(--hv-bg-primary);
      border-radius: 10px;
    }

    .metric-item .icon {
      width: 32px;
      height: 32px;
      background: rgba(223, 202, 97, 0.15);
      border-radius: 8px;
      display: flex;
      align-items: center;
      justify-content: center;
      flex-shrink: 0;
    }

    .metric-item .icon svg {
      width: 18px;
      height: 18px;
      stroke: var(--hv-accent-gold);
    }

    .metric-item .content {
      flex: 1;
      min-width: 0;
    }

    .metric-item .label {
      font-size: 10px;
      font-weight: 600;
      color: var(--hv-text-muted);
      text-transform: uppercase;
      letter-spacing: 0.5px;
      margin-bottom: 2px;
    }

    .metric-item .value {
      font-size: 14px;
      font-weight: 600;
      color: var(--hv-text-primary);
      line-height: 1.3;
    }

    /* Timer Card - Fuerza (right column) */
    .right-column .timer-card {
      display: flex;
      align-items: center;
      gap: 12px;
      padding: 20px;
      background: var(--hv-bg-secondary) !important;
      border-radius: 16px;
      border: none !important;
      flex-direction: row !important;
      flex: none !important;
    }

    .right-column .timer-icon {
      color: var(--hv-accent-gold);
    }

    .right-column .timer-value {
      font-size: 24px;
      font-weight: 700;
      color: var(--hv-text-primary);
      font-variant-numeric: tabular-nums;
    }

    .right-column .timer-label {
      font-size: 12px;
      color: var(--hv-text-muted);
    }

    .exercise-card {
      background: var(--hv-bg-secondary);
      border-radius: 16px;
      padding: 24px;
    }

    .exercise-name {
      font-size: 22px;
      font-weight: 600;
      color: var(--hv-text-primary);
      margin-bottom: 12px;
    }

    .exercise-tags {
      display: flex;
      gap: 8px;
      margin-bottom: 20px;
    }

    .tag {
      padding: 6px 12px;
      border-radius: 20px;
      font-size: 12px;
      font-weight: 500;
    }

    .tag-level {
      background: rgba(223, 202, 97, 0.2);
      color: var(--hv-accent-gold);
    }

    .tag-area {
      background: rgba(34, 197, 94, 0.2);
      color: var(--hv-accent-green);
    }

    /* Metrics */
    .metrics {
      display: flex;
      gap: 16px;
      margin-bottom: 20px;
    }

    .metric {
      flex: 1;
      text-align: center;
      padding: 16px;
      background: var(--hv-bg-primary);
      border-radius: 12px;
    }

    .metric-value {
      font-size: 24px;
      font-weight: 700;
      color: var(--hv-accent-gold);
    }

    .metric-label {
      font-size: 11px;
      color: var(--hv-text-muted);
      text-transform: uppercase;
      margin-top: 4px;
    }

    /* Instructions */
    .section-title {
      font-size: 13px;
      font-weight: 600;
      color: var(--hv-text-muted);
      text-transform: uppercase;
      letter-spacing: 0.5px;
      margin-bottom: 12px;
    }

    .instructions-list {
      list-style: none;
    }

    .instructions-list li {
      display: flex;
      gap: 10px;
      padding: 8px 0;
      font-size: 14px;
      color: var(--hv-text-secondary);
      line-height: 1.5;
    }

    .instructions-list li::before {
      content: attr(data-num);
      flex-shrink: 0;
      width: 22px;
      height: 22px;
      background: var(--hv-bg-card);
      border-radius: 50%;
      display: flex;
      align-items: center;
      justify-content: center;
      font-size: 11px;
      font-weight: 600;
      color: var(--hv-accent-gold);
    }

    /* Precautions */
    .precautions-card {
      background: rgba(239, 68, 68, 0.1);
      border: 1px solid rgba(239, 68, 68, 0.2);
      border-radius: 12px;
      padding: 16px;
    }

    .precautions-header {
      display: flex;
      align-items: center;
      gap: 8px;
      margin-bottom: 10px;
    }

    .precautions-icon {
      color: var(--hv-accent-red);
    }

    .precautions-title {
      font-size: 14px;
      font-weight: 600;
      color: var(--hv-accent-red);
    }

    .precautions-text {
      font-size: 13px;
      color: #CCAAAA;
      line-height: 1.5;
    }

    /* ============================================
       CARDIO: Guide Layout (sin timer)
       ============================================ */
    .cardio-left-column {
      width: 380px;
      flex-shrink: 0;
      display: flex;
      flex-direction: column;
      gap: 20px;
    }

    .cardio-right-column {
      flex: 1;
      display: flex;
      flex-direction: column;
      gap: 24px;
    }

    /* Reminder Card */
    .cardio-reminder-card {
      background: linear-gradient(135deg, rgba(223,202,97,0.15) 0%, rgba(223,202,97,0.05) 100%);
      border: 1px solid rgba(223,202,97,0.3);
      border-radius: 16px;
      padding: 20px;
    }

    .reminder-icon {
      font-size: 24px;
      margin-bottom: 12px;
    }

    .reminder-title {
      font-size: 16px;
      font-weight: 700;
      color: var(--hv-accent-gold);
      margin: 0 0 8px 0;
    }

    .reminder-text {
      font-size: 13px;
      color: var(--hv-text-secondary);
      line-height: 1.5;
      margin: 0;
    }

    .reminder-text strong {
      color: var(--hv-accent-gold);
    }

    /* Current Phase Card */
    .current-phase-card {
      background: linear-gradient(180deg, #1a2e1a 0%, var(--hv-bg-primary) 100%);
      border: 1px solid rgba(34, 197, 94, 0.2);
      border-radius: 24px;
      padding: 40px;
      display: flex;
      flex-direction: column;
      align-items: center;
      gap: 20px;
      flex: 1;
      justify-content: center;
    }

    .phase-badge {
      background: rgba(34, 197, 94, 0.2);
      color: var(--hv-accent-green);
      padding: 8px 20px;
      border-radius: 20px;
      font-size: 12px;
      font-weight: 600;
      text-transform: uppercase;
      letter-spacing: 1px;
    }

    .duration-target {
      display: flex;
      flex-direction: column;
      align-items: center;
      gap: 8px;
    }

    .duration-label {
      font-size: 14px;
      color: var(--hv-text-dim);
    }

    .duration-value {
      font-size: 48px;
      font-weight: 700;
      color: var(--hv-text-primary);
    }

    .intensity-row {
      display: flex;
      align-items: center;
      gap: 12px;
    }

    .intensity-label {
      font-size: 14px;
      color: var(--hv-text-muted);
    }

    .intensity-value {
      font-size: 14px;
      font-weight: 600;
      color: var(--hv-accent-green);
    }

    .phase-description {
      font-size: 15px;
      color: var(--hv-text-secondary);
      text-align: center;
      line-height: 1.6;
      max-width: 500px;
    }

    /* Phases Checklist */
    .phases-card {
      background: var(--hv-bg-secondary);
      border-radius: 16px;
      padding: 20px;
    }

    .phases-title {
      font-size: 11px;
      font-weight: 600;
      color: var(--hv-text-dim);
      text-transform: uppercase;
      letter-spacing: 1px;
      margin-bottom: 16px;
    }

    .phases-list {
      display: flex;
      flex-direction: column;
      gap: 10px;
    }

    .phase-item {
      display: flex;
      align-items: center;
      gap: 12px;
      padding: 14px;
      border-radius: 10px;
      background: var(--hv-bg-primary);
      transition: all 0.2s ease;
    }

    .phase-item.current {
      background: rgba(34, 197, 94, 0.1);
      border: 2px solid var(--hv-accent-green);
    }

    .phase-item.completed {
      background: var(--hv-bg-primary);
    }

    .phase-item.pending {
      background: var(--hv-bg-primary);
    }

    .phase-num {
      width: 24px;
      height: 24px;
      border-radius: 50%;
      display: flex;
      align-items: center;
      justify-content: center;
      font-size: 12px;
      font-weight: 700;
      flex-shrink: 0;
    }

    .phase-item.completed .phase-num {
      background: var(--hv-accent-green);
      color: white;
    }

    .phase-item.current .phase-num {
      background: var(--hv-accent-green);
      color: white;
    }

    .phase-item.pending .phase-num {
      background: var(--hv-border);
      color: var(--hv-text-dim);
    }

    .phase-content {
      flex: 1;
      min-width: 0;
    }

    .phase-name {
      font-size: 14px;
      font-weight: 500;
    }

    .phase-item.completed .phase-name {
      color: var(--hv-text-muted);
    }

    .phase-item.current .phase-name {
      color: var(--hv-accent-green);
      font-weight: 600;
    }

    .phase-item.pending .phase-name {
      color: var(--hv-text-dim);
    }

    .phase-time {
      font-size: 12px;
      margin-top: 2px;
    }

    .phase-item.completed .phase-time {
      color: var(--hv-accent-green);
    }

    .phase-item.current .phase-time {
      color: var(--hv-accent-green);
    }

    .phase-item.pending .phase-time {
      color: var(--hv-text-dim);
    }

    /* Alert Card */
    .alert-card {
      background: #2a1a1a;
      border: 1px solid rgba(239, 68, 68, 0.3);
      border-radius: 16px;
      padding: 20px;
    }

    .alert-header {
      display: flex;
      align-items: center;
      gap: 10px;
      margin-bottom: 12px;
    }

    .alert-icon {
      color: var(--hv-accent-red);
    }

    .alert-title {
      font-size: 15px;
      font-weight: 600;
      color: var(--hv-accent-red);
    }

    .alert-list {
      list-style: none;
    }

    .alert-list li {
      display: flex;
      gap: 8px;
      padding: 4px 0;
      font-size: 13px;
      color: #CCAAAA;
      line-height: 1.4;
    }

    .alert-list li::before {
      content: "•";
      color: var(--hv-accent-red);
    }

    /* ============================================
       FEEDBACK Section
       ============================================ */
    .feedback-section {
      display: none;
      padding: 48px 80px;
      max-width: 1200px;
      margin: 0 auto;
    }

    .feedback-section.active {
      display: flex;
      gap: 48px;
      align-items: flex-start;
      justify-content: center;
    }

    /* Celebration */
    .celebration-column {
      width: 480px;
      display: flex;
      flex-direction: column;
      align-items: center;
      gap: 32px;
    }

    .celebration-card {
      background: linear-gradient(180deg, #1a2e1a 0%, var(--hv-bg-primary) 100%);
      border: 1px solid rgba(34, 197, 94, 0.3);
      border-radius: 24px;
      padding: 40px;
      text-align: center;
      width: 100%;
    }

    .celebration-emoji {
      font-size: 64px;
      margin-bottom: 20px;
    }

    .celebration-title {
      font-size: 32px;
      font-weight: 700;
      color: var(--hv-accent-green);
      margin-bottom: 10px;
    }

    .celebration-subtitle {
      font-size: 16px;
      color: var(--hv-text-secondary);
    }

    /* Stats */
    .stats-row {
      display: flex;
      gap: 16px;
      width: 100%;
      justify-content: center;
    }

    .stat-card {
      width: 140px;
      padding: 20px 24px;
      background: var(--hv-bg-secondary);
      border-radius: 16px;
      text-align: center;
    }

    .stat-value {
      font-size: 36px;
      font-weight: 700;
      color: var(--hv-accent-gold);
    }

    .stat-label {
      font-size: 13px;
      color: var(--hv-text-muted);
      margin-top: 4px;
    }

    /* Feedback Form */
    .feedback-column {
      width: 480px;
    }

    .feedback-card {
      background: var(--hv-bg-secondary);
      border-radius: 20px;
      padding: 32px;
    }

    .feedback-title {
      font-size: 22px;
      font-weight: 600;
      color: var(--hv-text-primary);
      margin-bottom: 8px;
    }

    .feedback-subtitle {
      font-size: 14px;
      color: var(--hv-text-muted);
      margin-bottom: 24px;
    }

    .feedback-buttons {
      display: flex;
      flex-direction: column;
      gap: 12px;
    }

    .feedback-btn {
      display: flex;
      align-items: center;
      gap: 16px;
      padding: 20px 24px;
      background: var(--hv-bg-primary);
      border-radius: 14px;
      border: 2px solid transparent;
      cursor: pointer;
      transition: all 0.2s;
      text-decoration: none;
    }

    .feedback-btn:hover {
      transform: translateY(-2px);
    }

    .feedback-btn-easy {
      border-color: rgba(34, 197, 94, 0.3);
    }
    .feedback-btn-easy:hover {
      border-color: var(--hv-accent-green);
      background: rgba(34, 197, 94, 0.1);
    }

    .feedback-btn-good {
      border-color: rgba(223, 202, 97, 0.3);
    }
    .feedback-btn-good:hover {
      border-color: var(--hv-accent-gold);
      background: rgba(223, 202, 97, 0.1);
    }

    .feedback-btn-hard {
      border-color: rgba(239, 68, 68, 0.3);
    }
    .feedback-btn-hard:hover {
      border-color: var(--hv-accent-red);
      background: rgba(239, 68, 68, 0.1);
    }

    .feedback-emoji {
      font-size: 28px;
    }

    .feedback-content {
      flex: 1;
    }

    .feedback-btn-title {
      font-size: 17px;
      font-weight: 600;
    }

    .feedback-btn-easy .feedback-btn-title { color: var(--hv-accent-green); }
    .feedback-btn-good .feedback-btn-title { color: var(--hv-accent-gold); }
    .feedback-btn-hard .feedback-btn-title { color: var(--hv-accent-red); }

    .feedback-btn-desc {
      font-size: 13px;
      color: var(--hv-text-muted);
      margin-top: 4px;
    }

    .feedback-arrow {
      color: inherit;
      opacity: 0.5;
    }

    .feedback-btn-easy .feedback-arrow { color: var(--hv-accent-green); }
    .feedback-btn-good .feedback-arrow { color: var(--hv-accent-gold); }
    .feedback-btn-hard .feedback-arrow { color: var(--hv-accent-red); }

    /* Problems Link */
    .problems-link {
      display: flex;
      align-items: center;
      justify-content: center;
      gap: 8px;
      padding: 16px;
      color: var(--hv-text-dim);
      font-size: 13px;
      text-decoration: none;
      margin-top: 20px;
    }

    .problems-link:hover {
      color: var(--hv-text-secondary);
      text-decoration: underline;
    }

    /* ============================================
       Loading States
       ============================================ */
    .loading-state {
      display: none;
      flex-direction: column;
      align-items: center;
      justify-content: center;
      padding: 60px;
      text-align: center;
    }

    .loading-state.active {
      display: flex;
    }

    .spinner {
      width: 50px;
      height: 50px;
      border: 3px solid var(--hv-border);
      border-top-color: var(--hv-accent-green);
      border-radius: 50%;
      animation: spin 0.8s linear infinite;
      margin-bottom: 20px;
    }

    @keyframes spin {
      to { transform: rotate(360deg); }
    }

    .loading-text {
      font-size: 16px;
      color: var(--hv-text-secondary);
    }

    /* ============================================
       Responsive
       ============================================ */
    @media (max-width: 1100px) {
      .main-content {
        flex-direction: column;
        padding: 24px 20px;
        align-items: center;
        gap: 24px;
      }

      .left-column {
        width: 100%;
        max-width: 500px;
        order: 2;
      }

      .center-column {
        order: 1;
      }

      .right-column {
        width: 100%;
        max-width: 500px;
        order: 3;
      }

      .video-container {
        width: 280px;
        height: 500px;
      }

      .nav-section {
        width: 100%;
        max-width: 500px;
      }

      .progress-section {
        min-width: 200px;
      }

      .progress-bar-container {
        width: 200px;
      }

      .progress-text {
        font-size: 12px;
      }

      .metrics-row {
        justify-content: center;
      }

      .feedback-section.active {
        flex-direction: column;
        padding: 24px 20px;
      }

      .celebration-column,
      .feedback-column {
        width: 100%;
      }

      .big-timer {
        font-size: 64px;
      }
    }

    @media (max-width: 768px) {
      .header {
        padding: 0 16px;
        flex-wrap: wrap;
        height: auto;
        padding-top: 12px;
        padding-bottom: 12px;
        gap: 12px;
      }

      .logo {
        order: 1;
      }

      .progress-section {
        order: 2;
        width: 100%;
        min-width: unset;
      }

      /* Cardio responsive */
      .cardio-left-column {
        width: 100%;
        order: 2;
      }

      .cardio-right-column {
        order: 1;
      }

      .current-phase-card {
        padding: 30px 20px;
      }

      .duration-value {
        font-size: 36px;
      }

      .progress-bar-container {
        width: 100%;
        max-width: 280px;
      }

      .nav-btn {
        padding: 10px 16px;
        font-size: 13px;
      }

      .dots-row {
        gap: 4px;
      }

      .dot {
        width: 6px;
        height: 6px;
      }

      .dot.current {
        width: 16px;
      }

      .metrics {
        flex-wrap: wrap;
      }

      .metric {
        min-width: calc(50% - 8px);
      }

      .stats-row {
        flex-wrap: wrap;
      }

      .stat-card {
        width: calc(50% - 8px);
      }
    }

    /* Hidden utility */
    .hidden {
      display: none !important;
    }
  </style>
</head>
<body>
  <div class="app-container">
    <!-- Header with Progress Section -->
    <header class="header">
      <div class="logo">Camino Vital</div>

      <!-- Central Progress Section -->
      <div class="progress-section">
        <div class="progress-top">
          <span class="progress-icon" id="progressIcon">🔥</span>
          <span class="progress-text" id="progressText">¡Vamos! Ejercicio 1 de 8</span>
        </div>
        <div class="progress-bar-container">
          <div class="progress-fill" id="progressFill" style="width: 12.5%"></div>
        </div>
      </div>

      <!-- Spacer para mantener el logo a la izquierda y progreso centrado -->
      <div style="width: 100px;"></div>
    </header>

    <!-- FUERZA: Exercise View - 3 Column Layout -->
    <main class="main-content" id="fuerzaView">
      <!-- LEFT COLUMN: Exercise Info -->
      <div class="left-column">
        <div class="exercise-card">
          <h2 class="exercise-name" id="exerciseName">Cargando...</h2>
          <div class="exercise-tags" id="exerciseTags">
            <!-- Generated by JS -->
          </div>
          <div class="instructions-section">
            <h3 class="section-title">Instrucciones</h3>
            <ol class="instructions-list" id="instructionsList">
              <!-- Generated by JS -->
            </ol>
          </div>
        </div>
      </div>

      <!-- CENTER COLUMN: Portrait Video -->
      <div class="center-column">
        <div class="video-container" id="videoContainer">
          <video id="exerciseVideo" playsinline loop preload="metadata">
            <source src="" type="video/mp4">
          </video>
          <div class="video-placeholder" id="videoPlaceholder">
            <div class="play-button">
              <svg viewBox="0 0 24 24"><polygon points="5 3 19 12 5 21 5 3"/></svg>
            </div>
          </div>
        </div>

        <!-- Navigation Section - Dots + Buttons Separated -->
        <div class="nav-section">
          <!-- Dots Row -->
          <div class="dots-row" id="exerciseDots">
            <!-- Generated by JS -->
          </div>

          <!-- Buttons Row -->
          <div class="buttons-row">
            <button class="nav-btn nav-btn-prev" id="prevBtn" disabled>
              <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                <polyline points="15 18 9 12 15 6"></polyline>
              </svg>
              Anterior
            </button>

            <button class="nav-btn nav-btn-next" id="nextBtn">
              Siguiente
              <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                <polyline points="9 18 15 12 9 6"></polyline>
              </svg>
            </button>
          </div>

          <!-- Final Action Message -->
          <div class="final-message" id="finalMessage">
            <p class="final-message-text">🎯 ¡Pulsa TERMINAR para completar tu sesión!</p>
            <p class="final-message-subtext">Al finalizar recibirás tu siguiente sesión personalizada</p>
          </div>
        </div>
      </div>

      <!-- RIGHT COLUMN: Metrics & Timer -->
      <div class="right-column">
        <div class="metrics-card">
          <div class="metrics-title">Este ejercicio</div>
          <div class="metrics-list" id="exerciseMetrics">
            <!-- Generated by JS -->
          </div>
        </div>

        <div class="timer-card">
          <svg class="timer-icon" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
            <circle cx="12" cy="12" r="10"></circle>
            <polyline points="12 6 12 12 16 14"></polyline>
          </svg>
          <div>
            <div class="timer-value" id="sessionTimer">00:00</div>
            <div class="timer-label">tiempo transcurrido</div>
          </div>
        </div>

        <div class="precautions-card" id="precautionsCard">
          <div class="precautions-header">
            <svg class="precautions-icon" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
              <path d="M10.29 3.86L1.82 18a2 2 0 0 0 1.71 3h16.94a2 2 0 0 0 1.71-3L13.71 3.86a2 2 0 0 0-3.42 0z"></path>
              <line x1="12" y1="9" x2="12" y2="13"></line>
              <line x1="12" y1="17" x2="12.01" y2="17"></line>
            </svg>
            <span class="precautions-title">Precaución</span>
          </div>
          <p class="precautions-text" id="precautionsText"></p>
        </div>
      </div>
    </main>

    <!-- CARDIO: Guide View (sin timer en tiempo real) -->
    <main class="main-content hidden" id="cardioView">
      <!-- Left Column: Reminder + Phases Checklist -->
      <div class="cardio-left-column">
        <!-- Reminder Card -->
        <div class="cardio-reminder-card">
          <div class="reminder-icon">⚠️</div>
          <h3 class="reminder-title">Recuerda al terminar</h3>
          <p class="reminder-text">Cuando completes todas las fases, pulsa <strong>TERMINAR</strong> y da tu feedback. Así recibirás tu siguiente sesión personalizada.</p>
        </div>

        <!-- Phases Checklist -->
        <div class="phases-card">
          <h3 class="phases-title">TU SESIÓN DE HOY</h3>
          <div class="phases-list" id="phasesList">
            <!-- Generated by JS -->
          </div>
        </div>
      </div>

      <!-- Right Column: Current Phase Details -->
      <div class="cardio-right-column">
        <!-- Current Phase Card -->
        <div class="current-phase-card">
          <div class="phase-badge" id="phaseBadge">FASE ACTUAL</div>
          <div class="duration-target">
            <span class="duration-label">Duración objetivo</span>
            <span class="duration-value" id="phaseTimeTarget">12-14 minutos</span>
          </div>
          <div class="intensity-row">
            <span class="intensity-label">Intensidad:</span>
            <span class="intensity-value" id="intensityValue">Moderada (5-6/10)</span>
          </div>
          <p class="phase-description" id="phaseDescription">
            Descripción de la fase actual.
          </p>
        </div>

        <!-- Navigation Section -->
        <div class="nav-section">
          <div class="dots-row" id="phaseDots">
            <!-- Generated by JS -->
          </div>
          <div class="buttons-row">
            <button class="nav-btn nav-btn-prev" id="phasePrevBtn" disabled>
              <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                <polyline points="15 18 9 12 15 6"></polyline>
              </svg>
              Anterior
            </button>
            <button class="nav-btn nav-btn-next" id="phaseNextBtn">
              Siguiente
              <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                <polyline points="9 18 15 12 9 6"></polyline>
              </svg>
            </button>
          </div>
          <!-- Final Action Message for Cardio -->
          <div class="final-message" id="cardioFinalMessage">
            <p class="final-message-text">🎯 ¡Pulsa TERMINAR para completar tu sesión!</p>
            <p class="final-message-subtext">Al finalizar recibirás tu siguiente sesión personalizada</p>
          </div>
        </div>

        <!-- Alert Card -->
        <div class="alert-card">
          <div class="alert-header">
            <svg class="alert-icon" width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
              <path d="M10.29 3.86L1.82 18a2 2 0 0 0 1.71 3h16.94a2 2 0 0 0 1.71-3L13.71 3.86a2 2 0 0 0-3.42 0z"></path>
              <line x1="12" y1="9" x2="12" y2="13"></line>
              <line x1="12" y1="17" x2="12.01" y2="17"></line>
            </svg>
            <span class="alert-title">Señales de alerta - Para inmediatamente si:</span>
          </div>
          <ul class="alert-list" id="alertList">
            <li>Dolor o presión en el pecho</li>
            <li>Mareo intenso o náuseas</li>
            <li>Dificultad extrema para respirar</li>
          </ul>
        </div>
      </div>
    </main>

    <!-- Feedback Section -->
    <section class="feedback-section" id="feedbackSection">
      <div class="celebration-column">
        <div class="celebration-card">
          <div class="celebration-emoji">🎉</div>
          <h2 class="celebration-title">¡Sesión Completada!</h2>
          <p class="celebration-subtitle">Has dado un paso más hacia tus objetivos</p>
        </div>
        <div class="stats-row">
          <div class="stat-card">
            <div class="stat-value" id="statExercises">8</div>
            <div class="stat-label">Ejercicios</div>
          </div>
          <div class="stat-card">
            <div class="stat-value" id="statTime">00:00</div>
            <div class="stat-label">Minutos</div>
          </div>
          <div class="stat-card">
            <div class="stat-value" id="statWeek">{{numero_sesion}}/{{sesiones_objetivo}}</div>
            <div class="stat-label">Semana</div>
          </div>
        </div>
      </div>

      <div class="feedback-column">
        <div class="feedback-card">
          <h2 class="feedback-title">¿Cómo te fue la sesión?</h2>
          <p class="feedback-subtitle">Tu feedback nos ayuda a personalizar tu programa</p>

          <div class="feedback-buttons">
            <a href="{{webhook_url}}/webhook/sesion-completada?user_id={{user_id}}&sesion={{numero_sesion}}&feedback=completa_facil" class="feedback-btn feedback-btn-easy">
              <span class="feedback-emoji">😊</span>
              <div class="feedback-content">
                <div class="feedback-btn-title">Fue fácil</div>
                <div class="feedback-btn-desc">Podría haber hecho más</div>
              </div>
              <svg class="feedback-arrow" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                <polyline points="9 18 15 12 9 6"></polyline>
              </svg>
            </a>

            <a href="{{webhook_url}}/webhook/sesion-completada?user_id={{user_id}}&sesion={{numero_sesion}}&feedback=completa_bien" class="feedback-btn feedback-btn-good">
              <span class="feedback-emoji">✅</span>
              <div class="feedback-content">
                <div class="feedback-btn-title">Estuvo bien</div>
                <div class="feedback-btn-desc">El nivel fue adecuado para mí</div>
              </div>
              <svg class="feedback-arrow" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                <polyline points="9 18 15 12 9 6"></polyline>
              </svg>
            </a>

            <a href="{{webhook_url}}/webhook/sesion-completada?user_id={{user_id}}&sesion={{numero_sesion}}&feedback=completa_dificil" class="feedback-btn feedback-btn-hard">
              <span class="feedback-emoji">😓</span>
              <div class="feedback-content">
                <div class="feedback-btn-title">Fue difícil</div>
                <div class="feedback-btn-desc">Me costó completar los ejercicios</div>
              </div>
              <svg class="feedback-arrow" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                <polyline points="9 18 15 12 9 6"></polyline>
              </svg>
            </a>
          </div>

          <a href="{{feedback_problemas_url}}" class="problems-link">
            <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
              <path d="M21 15a2 2 0 0 1-2 2H7l-4 4V5a2 2 0 0 1 2-2h14a2 2 0 0 1 2 2z"></path>
            </svg>
            ¿No pudiste completar la sesión? Cuéntanos qué pasó
          </a>
        </div>
      </div>
    </section>

    <!-- Loading State -->
    <div class="loading-state" id="loadingState">
      <div class="spinner"></div>
      <p class="loading-text">Enviando tu feedback...</p>
    </div>
  </div>

  <script>
    // ============================================
    // Session Data (injected by workflow)
    // ============================================
    const SESSION_DATA = {{session_json}};

    // ============================================
    // App State
    // ============================================
    const state = {
      currentIndex: 0,
      timerStarted: false,
      timerSeconds: 0,
      timerInterval: null,
      isCardio: false,
      exercises: [],
      phases: []
    };

    // ============================================
    // Firebase Video URL Helper
    // ============================================
    const FIREBASE_BASE = "https://firebasestorage.googleapis.com/v0/b/playfit-21e92.appspot.com/o/video%2F";
    const FIREBASE_TOKEN = "?alt=media";

    function getVideoUrl(filename) {
      return FIREBASE_BASE + encodeURIComponent(filename) + FIREBASE_TOKEN;
    }

    // ============================================
    // Initialize
    // ============================================
    function init() {
      // Determine session type
      state.isCardio = SESSION_DATA.enfoque === "cardio" ||
                       (!SESSION_DATA.calentamiento && !SESSION_DATA.trabajo_principal);

      if (state.isCardio) {
        initCardioSession();
      } else {
        initFuerzaSession();
      }
    }

    // ============================================
    // FUERZA Session
    // ============================================
    function initFuerzaSession() {
      document.getElementById("cardioView").classList.add("hidden");
      document.getElementById("fuerzaView").classList.remove("hidden");

      // Combine calentamiento + trabajo_principal
      const calentamiento = SESSION_DATA.calentamiento || [];
      const trabajoPrincipal = SESSION_DATA.trabajo_principal || [];

      state.exercises = [
        ...calentamiento.map((ex, i) => ({ ...ex, type: "calentamiento", index: i })),
        ...trabajoPrincipal.map((ex, i) => ({ ...ex, type: "principal", index: i }))
      ];

      if (state.exercises.length === 0) {
        alert("No hay ejercicios en esta sesión");
        return;
      }

      // Generate dots
      generateExerciseDots();

      // Set up navigation
      document.getElementById("prevBtn").addEventListener("click", goToPrevExercise);
      document.getElementById("nextBtn").addEventListener("click", goToNextExercise);

      // Set up video
      const video = document.getElementById("exerciseVideo");
      const placeholder = document.getElementById("videoPlaceholder");

      placeholder.addEventListener("click", () => {
        placeholder.style.display = "none";
        video.play();
        startTimer();
      });

      video.addEventListener("play", startTimer);

      // Load first exercise
      loadExercise(0);
    }

    function generateExerciseDots() {
      const container = document.getElementById("exerciseDots");
      container.innerHTML = "";

      state.exercises.forEach((_, i) => {
        const dot = document.createElement("div");
        dot.className = "dot" + (i === 0 ? " current" : "");
        dot.addEventListener("click", () => goToExercise(i));
        container.appendChild(dot);
      });
    }

    function updateExerciseDots() {
      const dots = document.querySelectorAll("#exerciseDots .dot");
      dots.forEach((dot, i) => {
        dot.classList.remove("current", "completed");
        if (i < state.currentIndex) {
          dot.classList.add("completed");
        } else if (i === state.currentIndex) {
          dot.classList.add("current");
        }
      });
    }

    function loadExercise(index) {
      const ex = state.exercises[index];
      state.currentIndex = index;

      const total = state.exercises.length;
      const current = index + 1;
      const progress = (current / total) * 100;

      // Update progress bar
      const progressFill = document.getElementById("progressFill");
      progressFill.style.width = progress + "%";

      // Update motivational state
      updateMotivationalState(current, total);

      // Update exercise name
      document.getElementById("exerciseName").textContent = ex.nombre_espanol || ex.nombre || "Ejercicio";

      // Update tags
      const tagsContainer = document.getElementById("exerciseTags");
      tagsContainer.innerHTML = "";

      if (ex.nivel) {
        const levelTag = document.createElement("span");
        levelTag.className = "tag tag-level";
        levelTag.textContent = ex.nivel.charAt(0).toUpperCase() + ex.nivel.slice(1);
        tagsContainer.appendChild(levelTag);
      }

      if (ex.areas_cuerpo && ex.areas_cuerpo.length > 0) {
        const areaTag = document.createElement("span");
        areaTag.className = "tag tag-area";
        areaTag.textContent = ex.areas_cuerpo[0];
        tagsContainer.appendChild(areaTag);
      }

      // Update metrics - New list format
      const metricsContainer = document.getElementById("exerciseMetrics");
      metricsContainer.innerHTML = "";

      if (ex.repeticiones) {
        metricsContainer.innerHTML += `
          <div class="metric-item">
            <div class="icon">
              <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                <path d="M17 3a2.85 2.83 0 1 1 4 4L7.5 20.5 2 22l1.5-5.5L17 3Z"/>
              </svg>
            </div>
            <div class="content">
              <div class="label">Repeticiones</div>
              <div class="value">${ex.repeticiones}</div>
            </div>
          </div>
        `;
      }

      if (ex.duracion_aprox) {
        metricsContainer.innerHTML += `
          <div class="metric-item">
            <div class="icon">
              <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                <circle cx="12" cy="12" r="10"></circle>
                <polyline points="12 6 12 12 16 14"></polyline>
              </svg>
            </div>
            <div class="content">
              <div class="label">Duración aproximada</div>
              <div class="value">${ex.duracion_aprox}</div>
            </div>
          </div>
        `;
      }

      // Update instructions
      const instructionsList = document.getElementById("instructionsList");
      instructionsList.innerHTML = "";

      // El Generador usa "notas" (string) en lugar de "instrucciones_clave" (array)
      const notas = ex.notas || ex.instrucciones_clave || null;
      if (notas) {
        // Si es string, mostrar como una sola instrucción
        if (typeof notas === "string") {
          const li = document.createElement("li");
          li.setAttribute("data-num", "1");
          li.textContent = notas;
          instructionsList.appendChild(li);
        } else if (Array.isArray(notas)) {
          // Si es array, mostrar cada elemento
          notas.forEach((instruction, i) => {
            const li = document.createElement("li");
            li.setAttribute("data-num", i + 1);
            li.textContent = instruction;
            instructionsList.appendChild(li);
          });
        }
      } else {
        // Fallback si no hay notas
        const li = document.createElement("li");
        li.setAttribute("data-num", "•");
        li.textContent = "Sigue el video para realizar el ejercicio correctamente";
        instructionsList.appendChild(li);
      }

      // Update precautions
      const precautionsCard = document.getElementById("precautionsCard");
      const precautionsText = document.getElementById("precautionsText");

      if (ex.precauciones && ex.precauciones.length > 0) {
        precautionsCard.classList.remove("hidden");
        precautionsText.textContent = ex.precauciones.join(" ");
      } else {
        precautionsCard.classList.add("hidden");
      }

      // Update video
      const video = document.getElementById("exerciseVideo");
      const placeholder = document.getElementById("videoPlaceholder");

      if (ex.firebase_url || ex.nombre_archivo) {
        const videoUrl = ex.firebase_url || getVideoUrl(ex.nombre_archivo);
        video.src = videoUrl;
        video.load();

        // Si ya se inició la sesión (timer running), auto-play
        if (state.timerStarted) {
          placeholder.style.display = "none";
          video.play();
        } else {
          placeholder.style.display = "flex";
        }
      }

      // Update dots
      updateExerciseDots();

      // Update navigation buttons
      document.getElementById("prevBtn").disabled = index === 0;

      const nextBtn = document.getElementById("nextBtn");
      const finalMessage = document.getElementById("finalMessage");
      const isLastExercise = index === state.exercises.length - 1;

      if (isLastExercise) {
        nextBtn.innerHTML = `
          🏆 ¡TERMINAR SESIÓN!
          <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
            <polyline points="20 6 9 17 4 12"></polyline>
          </svg>
        `;
        finalMessage.classList.add("visible");
      } else {
        nextBtn.innerHTML = `
          Siguiente
          <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
            <polyline points="9 18 15 12 9 6"></polyline>
          </svg>
        `;
        finalMessage.classList.remove("visible");
      }
    }

    // ============================================
    // Motivational Progress States
    // ============================================
    function updateMotivationalState(current, total) {
      const progressIcon = document.getElementById("progressIcon");
      const progressText = document.getElementById("progressText");
      const progressFill = document.getElementById("progressFill");
      const nextBtn = document.getElementById("nextBtn");

      const remaining = total - current;
      const isLast = current === total;
      const isNearEnd = remaining <= 2 && remaining > 0;
      const isMiddle = current > 1 && remaining > 2;

      // Remove previous state classes
      progressText.classList.remove("final");
      progressFill.classList.remove("final", "pulse");
      nextBtn.classList.remove("final");

      if (isLast) {
        // ÚLTIMO EJERCICIO - Gold/celebration state
        progressIcon.textContent = "🏆";
        progressText.textContent = "¡ÚLTIMO EJERCICIO! ¡Ya casi lo logras!";
        progressText.classList.add("final");
        progressFill.classList.add("final", "pulse");
        nextBtn.classList.add("final");
      } else if (isNearEnd) {
        // NEAR END (2-3 remaining) - Encouraging
        progressIcon.textContent = "💪";
        progressText.textContent = `¡Vas genial! Solo quedan ${remaining} ejercicios`;
        progressFill.classList.add("pulse");
      } else if (isMiddle) {
        // MIDDLE - Keep going
        progressIcon.textContent = "🔥";
        progressText.textContent = `¡Vas muy bien! Ejercicio ${current} de ${total}`;
      } else {
        // START
        progressIcon.textContent = "🚀";
        progressText.textContent = `¡Vamos! Ejercicio ${current} de ${total}`;
      }
    }

    function goToExercise(index) {
      if (index >= 0 && index < state.exercises.length) {
        loadExercise(index);
      }
    }

    function goToPrevExercise() {
      if (state.currentIndex > 0) {
        loadExercise(state.currentIndex - 1);
      }
    }

    function goToNextExercise() {
      if (state.currentIndex < state.exercises.length - 1) {
        loadExercise(state.currentIndex + 1);
      } else {
        // Show feedback section
        showFeedback();
      }
    }

    // ============================================
    // CARDIO Session
    // ============================================
    function initCardioSession() {
      document.getElementById("fuerzaView").classList.add("hidden");
      document.getElementById("cardioView").classList.remove("hidden");

      // Parse phases from actividad_principal
      const actividad = SESSION_DATA.actividad_principal || {};
      state.phases = actividad.fases || [];

      if (state.phases.length === 0) {
        // Fallback phases
        state.phases = [
          { fase: "Calentamiento", duracion: "5 minutos", intensidad: "Baja", descripcion: "Preparación" },
          { fase: "Actividad principal", duracion: "15 minutos", intensidad: "Moderada", descripcion: "Trabajo" },
          { fase: "Enfriamiento", duracion: "5 minutos", intensidad: "Baja", descripcion: "Recuperación" }
        ];
      }

      // Generate phase dots and list
      generatePhaseDots();
      generatePhasesList();

      // Populate alerts from dynamic data
      const alertList = document.getElementById("alertList");
      const senales = SESSION_DATA.senales_de_alerta || [];
      if (senales.length > 0) {
        alertList.innerHTML = "";
        senales.forEach(senal => {
          const li = document.createElement("li");
          li.textContent = senal;
          alertList.appendChild(li);
        });
      }

      // Set up navigation
      document.getElementById("phasePrevBtn").addEventListener("click", goToPrevPhase);
      document.getElementById("phaseNextBtn").addEventListener("click", goToNextPhase);

      // Load first phase
      loadPhase(0);

      // NO timer automático para cardio - el usuario controla el ritmo
    }

    function generatePhaseDots() {
      const container = document.getElementById("phaseDots");
      container.innerHTML = "";

      state.phases.forEach((_, i) => {
        const dot = document.createElement("div");
        dot.className = "dot" + (i === 0 ? " current" : "");
        dot.addEventListener("click", () => goToPhase(i));
        container.appendChild(dot);
      });
    }

    function generatePhasesList() {
      const container = document.getElementById("phasesList");
      container.innerHTML = "";

      state.phases.forEach((phase, i) => {
        const item = document.createElement("div");
        item.className = "phase-item" + (i === 0 ? " current" : " pending");
        item.id = "phaseItem" + i;
        item.style.cursor = "pointer";
        item.addEventListener("click", () => goToPhase(i));

        const statusText = i === 0 ? "En progreso" : "Pendiente";

        item.innerHTML = `
          <div class="phase-num">${i + 1}</div>
          <div class="phase-content">
            <div class="phase-name">${phase.fase}</div>
            <div class="phase-time">${phase.duracion} · ${statusText}</div>
          </div>
        `;

        container.appendChild(item);
      });
    }

    function updatePhasesList() {
      state.phases.forEach((phase, i) => {
        const item = document.getElementById("phaseItem" + i);
        if (!item) return;

        item.classList.remove("completed", "current", "pending");

        let statusText;
        if (i < state.currentIndex) {
          item.classList.add("completed");
          statusText = "Completado ✓";
          item.querySelector(".phase-num").innerHTML = "✓";
        } else if (i === state.currentIndex) {
          item.classList.add("current");
          statusText = "En progreso";
          item.querySelector(".phase-num").textContent = i + 1;
        } else {
          item.classList.add("pending");
          statusText = "Pendiente";
          item.querySelector(".phase-num").textContent = i + 1;
        }

        item.querySelector(".phase-time").textContent = `${phase.duracion} · ${statusText}`;
      });
    }

    function loadPhase(index) {
      const phase = state.phases[index];
      state.currentIndex = index;

      const total = state.phases.length;
      const current = index + 1;
      const progress = (current / total) * 100;

      // Update progress bar
      document.getElementById("progressFill").style.width = progress + "%";

      // Update motivational state
      updateMotivationalStateCardio(current, total);

      // Update phase info - Duration as TARGET, not timer
      document.getElementById("phaseBadge").textContent = phase.fase.toUpperCase();
      document.getElementById("phaseTimeTarget").textContent = phase.duracion;
      document.getElementById("intensityValue").textContent = phase.intensidad || "Moderada (5-6/10)";
      document.getElementById("phaseDescription").textContent = phase.descripcion || "";

      // Update dots
      const dots = document.querySelectorAll("#phaseDots .dot");
      dots.forEach((dot, i) => {
        dot.classList.remove("current", "completed");
        if (i < index) {
          dot.classList.add("completed");
        } else if (i === index) {
          dot.classList.add("current");
        }
      });

      // Update list
      updatePhasesList();

      // Update navigation
      document.getElementById("phasePrevBtn").disabled = index === 0;

      const nextBtn = document.getElementById("phaseNextBtn");
      const finalMessage = document.getElementById("cardioFinalMessage");
      const isLastPhase = index === state.phases.length - 1;

      if (isLastPhase) {
        nextBtn.innerHTML = `
          🏆 ¡TERMINAR SESIÓN!
          <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
            <polyline points="20 6 9 17 4 12"></polyline>
          </svg>
        `;
        nextBtn.classList.add("final");
        if (finalMessage) finalMessage.classList.add("visible");
      } else {
        nextBtn.innerHTML = `
          Siguiente
          <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
            <polyline points="9 18 15 12 9 6"></polyline>
          </svg>
        `;
        nextBtn.classList.remove("final");
        if (finalMessage) finalMessage.classList.remove("visible");
      }
    }

    function updateMotivationalStateCardio(current, total) {
      const progressIcon = document.getElementById("progressIcon");
      const progressText = document.getElementById("progressText");
      const progressFill = document.getElementById("progressFill");
      const nextBtn = document.getElementById("phaseNextBtn");

      const remaining = total - current;
      const isLast = current === total;

      // Remove previous state classes
      progressText.classList.remove("final");
      progressFill.classList.remove("final", "pulse");
      nextBtn.classList.remove("final");

      if (isLast) {
        progressIcon.textContent = "🏆";
        progressText.textContent = "¡ÚLTIMA FASE! ¡Ya casi terminas!";
        progressText.classList.add("final");
        progressFill.classList.add("final", "pulse");
        nextBtn.classList.add("final");
      } else if (remaining === 1) {
        progressIcon.textContent = "💪";
        progressText.textContent = "¡Genial! Solo queda 1 fase más";
        progressFill.classList.add("pulse");
      } else {
        progressIcon.textContent = "❤️";
        progressText.textContent = `Fase ${current} de ${total}`;
      }
    }

    function goToPhase(index) {
      if (index >= 0 && index < state.phases.length) {
        loadPhase(index);
      }
    }

    function goToPrevPhase() {
      if (state.currentIndex > 0) {
        loadPhase(state.currentIndex - 1);
      }
    }

    function goToNextPhase() {
      if (state.currentIndex < state.phases.length - 1) {
        loadPhase(state.currentIndex + 1);
      } else {
        showFeedback();
      }
    }

    // ============================================
    // Timer
    // ============================================
    function startTimer() {
      if (state.timerStarted) return;
      state.timerStarted = true;

      state.timerInterval = setInterval(() => {
        state.timerSeconds++;
        updateTimerDisplay();
      }, 1000);
    }

    function updateTimerDisplay() {
      const minutes = Math.floor(state.timerSeconds / 60);
      const seconds = state.timerSeconds % 60;
      const formatted = String(minutes).padStart(2, "0") + ":" + String(seconds).padStart(2, "0");

      // Update both timers
      const sessionTimer = document.getElementById("sessionTimer");
      const cardioTimer = document.getElementById("cardioTimer");

      if (sessionTimer) sessionTimer.textContent = formatted;
      if (cardioTimer) cardioTimer.textContent = formatted;
    }

    function stopTimer() {
      if (state.timerInterval) {
        clearInterval(state.timerInterval);
        state.timerInterval = null;
      }
    }

    // ============================================
    // Feedback
    // ============================================
    function showFeedback() {
      stopTimer();

      // Hide main views
      document.getElementById("fuerzaView").classList.add("hidden");
      document.getElementById("cardioView").classList.add("hidden");

      // Hide progress section in header
      const progressSection = document.querySelector(".progress-section");
      if (progressSection) progressSection.classList.add("hidden");

      // Update stats
      const totalExercises = state.isCardio ? state.phases.length : state.exercises.length;
      document.getElementById("statExercises").textContent = state.isCardio
        ? totalExercises + " fases"
        : totalExercises;

      // For fuerza show timer, for cardio show checkmark
      if (state.isCardio) {
        document.getElementById("statTime").textContent = "✓";
        document.querySelector("#statTime + .stat-label").textContent = "Completado";
      } else {
        const minutes = Math.floor(state.timerSeconds / 60);
        const seconds = state.timerSeconds % 60;
        document.getElementById("statTime").textContent =
          String(minutes).padStart(2, "0") + ":" + String(seconds).padStart(2, "0");
      }

      // Show feedback section
      document.getElementById("feedbackSection").classList.add("active");
    }

    // ============================================
    // Start App
    // ============================================
    document.addEventListener("DOMContentLoaded", init);
  </script>
</body>
</html>',
  '["titulo", "user_nombre", "user_id", "numero_sesion", "sesiones_objetivo", "webhook_url", "feedback_problemas_url", "session_json"]'::jsonb,
  1,
  true
)
ON CONFLICT (nombre, version) DO UPDATE SET
  html_template = EXCLUDED.html_template,
  variables_requeridas = EXCLUDED.variables_requeridas,
  updated_at = NOW();

-- Añadir comentario
COMMENT ON TABLE email_templates IS 'Templates de HTML para emails y páginas web';
