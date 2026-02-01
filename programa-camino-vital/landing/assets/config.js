// Configuracion centralizada de Camino Vital
const CONFIG = {
    // WhatsApp - dejar numero vacio para mostrar solo email
    whatsapp: {
        numero: '34623920880',  // +34 623 920 880
        mensaje: 'Hola, tengo una duda sobre Camino Vital'
    },
    email: 'hola@habitos-vitales.com'
};

// Helper: genera el link de WhatsApp o null si no hay numero
function getWhatsAppLink() {
    if (!CONFIG.whatsapp.numero) return null;
    return 'https://wa.me/' + CONFIG.whatsapp.numero + '?text=' + encodeURIComponent(CONFIG.whatsapp.mensaje);
}

// Helper: genera el HTML de contacto (WhatsApp + Email o solo Email)
function getContactHTML() {
    const whatsappLink = getWhatsAppLink();
    const emailLink = '<a href="mailto:' + CONFIG.email + '">' + CONFIG.email + '</a>';

    if (whatsappLink) {
        return '<a href="' + whatsappLink + '" target="_blank">WhatsApp</a> o a ' + emailLink;
    }
    return emailLink;
}

// Auto-inicializar elementos con clase 'contact-info' cuando el DOM este listo
document.addEventListener('DOMContentLoaded', function() {
    var contactElements = document.querySelectorAll('.contact-info');
    contactElements.forEach(function(el) {
        el.innerHTML = getContactHTML();
    });
});
