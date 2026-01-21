# Guía: Modificar Distribución de Tipos de Sesión

## ¿Dónde está el código?

La matriz de distribución está en el **Workflow 01-bis**, nodo **"Preparar Prompt Claude"**, líneas 18-54.

## ¿Cómo funciona?

La matriz define qué tipo de sesión se genera según:
- **Objetivo del usuario** (movilidad, fuerza, equilibrio, cardio, general)
- **Número de sesiones semanales** (2-5)
- **Número de sesión en la semana** (1ª, 2ª, 3ª, etc.)

## Ejemplo de modificación

### ANTES: Usuario con objetivo "fuerza" y 3 sesiones/semana
```javascript
'fuerza': {
  3: ['fuerza', 'cardio', 'fuerza']
}
```
→ Semana: Fuerza → Cardio → Fuerza

### DESPUÉS: Quieres que haga 2 de fuerza y 1 de movilidad
```javascript
'fuerza': {
  3: ['fuerza', 'fuerza', 'movilidad']
}
```
→ Semana: Fuerza → Fuerza → Movilidad

## Matriz completa actual

```javascript
const matrizDistribucion = {
  'movilidad': {
    2: ['movilidad', 'fuerza'],
    3: ['movilidad', 'fuerza', 'movilidad'],
    4: ['movilidad', 'fuerza', 'cardio', 'movilidad'],
    5: ['movilidad', 'fuerza', 'cardio', 'movilidad', 'equilibrio']
  },
  'fuerza': {
    2: ['fuerza', 'cardio'],
    3: ['fuerza', 'cardio', 'fuerza'],
    4: ['fuerza', 'cardio', 'fuerza', 'movilidad'],
    5: ['fuerza', 'cardio', 'fuerza', 'movilidad', 'fuerza']
  },
  'equilibrio': {
    2: ['equilibrio', 'fuerza'],
    3: ['equilibrio', 'fuerza', 'equilibrio'],
    4: ['equilibrio', 'fuerza', 'movilidad', 'equilibrio'],
    5: ['equilibrio', 'fuerza', 'movilidad', 'cardio', 'equilibrio']
  },
  'cardio': {
    2: ['cardio', 'fuerza'],
    3: ['cardio', 'fuerza', 'cardio'],
    4: ['cardio', 'fuerza', 'cardio', 'movilidad'],
    5: ['cardio', 'fuerza', 'cardio', 'movilidad', 'cardio']
  },
  'general': {
    2: ['fuerza', 'cardio'],
    3: ['fuerza', 'cardio', 'movilidad'],
    4: ['fuerza', 'cardio', 'movilidad', 'equilibrio'],
    5: ['fuerza', 'cardio', 'movilidad', 'equilibrio', 'fuerza']
  }
};
```

## Tipos de sesión disponibles

Puedes usar cualquiera de estos valores en los arrays:
- `'fuerza'` - Sentadillas, flexiones, planchas, ejercicios de core
- `'cardio'` - Jumping jacks, burpees, high knees, saltos
- `'movilidad'` - Estiramientos, movimientos articulares, flexibilidad
- `'equilibrio'` - Ejercicios unilaterales, posturas en una pierna
- `'mixto'` - Combinación de todos los anteriores

## Pasos para modificar

1. Abrir n8n → Workflow "01-bis Seleccionar Sesiones"
2. Click en nodo **"Preparar Prompt Claude"**
3. Buscar el objeto `matrizDistribucion`
4. Editar el array correspondiente
5. Guardar el workflow
6. ¡Listo! Los cambios aplican inmediatamente

## Ejemplo práctico

Si quieres que usuarios con objetivo "movilidad" y 4 sesiones/semana hagan:
- Lunes: Movilidad
- Miércoles: Movilidad
- Viernes: Fuerza
- Domingo: Equilibrio

Solo cambias:
```javascript
'movilidad': {
  4: ['movilidad', 'movilidad', 'fuerza', 'equilibrio']  // ← Cambio aquí
}
```

**¡Es así de simple!** 🎯
