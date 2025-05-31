#!/bin/bash

# Ruta del archivo a modificar
archivo_config="$HOME/.config/bspwm/bspwmrc"  # O donde esté tu línea con feh

# Ruta base donde están tus fondos
carpeta_fondos="$HOME/Wallpapers"

# Mostrar menú
echo "Elige un fondo de pantalla:"
select fondo in \
  "archkali.png" \
  "fondo.jpg" \
  "s4vitar.png" \
  "wall-05.png" \
  "wallhaven-dgorzl.jpg" \
  "wallhaven-ne791l.png" \
  "wallpaperarch.png"
do
  if [ -n "$fondo" ]; then
    ruta_fondo="$carpeta_fondos/$fondo"

    # Confirmar si el archivo existe
    if [ -f "$ruta_fondo" ]; then
      # Reemplazar en el archivo la línea que contiene "feh --bg-fill"
      sed -i "s|feh --bg-fill .*|feh --bg-fill $ruta_fondo \&|" "$archivo_config"
      echo "Fondo actualizado a: $fondo"
      bspc wm -r
      break
    else
      echo "Archivo no encontrado: $ruta_fondo"
    fi
  else
    echo "Opción no válida."
  fi
done



