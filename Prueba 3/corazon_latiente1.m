clc
clear 
close all

function corazon_latiente_3D_con_ECG_mejorado
   % Simulación de un corazón latiendo en 3D con visualización de ECG mejorada y cuerpo humano
   % Ajustes anatómicos: cabeza arriba del torso, brazos a los lados, piernas por debajo,
   % corazón en el tórax (ligeramente a la izquierda).
  
   % Variables globales para la animación
   global h frecuencia_lpm tiempo_total fps ecg_ax ecg_line tiempo_ecg senal_ecg cuerpo_parts;
  
   % Valores iniciales
   frecuencia_lpm = 72; % latidos por minuto iniciales
   tiempo_total = 30; % segundos
   fps = 30; % frames por segundo
  
   % Configuración de la figura principal
   fig = figure('Name', 'Corazón Latiente 3D con Cuerpo Humano y ECG', ...
               'Position', [50, 50, 1400, 700], ...
               'Color', 'white', ...
               'NumberTitle', 'off');
  
   % Panel para controles
   panel_control = uipanel('Parent', fig, ...
                          'Title', 'Controles', ...
                          'Position', [0.82 0.05 0.16 0.25], ...
                          'BackgroundColor', [0.95 0.95 0.95], ...
                          'FontWeight', 'bold');
  
   % Slider para frecuencia cardiaca
   uicontrol('Parent', panel_control, ...
            'Style', 'text', ...
            'String', 'Latidos por Minuto (LPM):', ...
            'Position', [10 120 140 20], ...
            'BackgroundColor', [0.95 0.95 0.95], ...
            'HorizontalAlignment', 'left', ...
            'FontSize', 9);
  
   slider_lpm = uicontrol('Parent', panel_control, ...
                         'Style', 'slider', ...
                         'Min', 40, ...
                         'Max', 120, ...
                         'Value', frecuencia_lpm, ...
                         'Position', [10 90 130 20], ...
                         'Callback', @actualizar_frecuencia);
  
   % Texto que muestra el valor actual del slider
   texto_lpm = uicontrol('Parent', panel_control, ...
                        'Style', 'text', ...
                        'String', sprintf('%d LPM', frecuencia_lpm), ...
                        'Position', [150 90 40 20], ...
                        'BackgroundColor', [0.95 0.95 0.95], ...
                        'FontSize', 9);
  
   % Botón para iniciar/pausar
   btn_iniciar = uicontrol('Parent', panel_control, ...
                          'Style', 'pushbutton', ...
                          'String', 'Iniciar', ...
                          'Position', [10 50 60 30], ...
                          'Callback', @iniciar_animacion, ...
                          'BackgroundColor', [0.8 0.9 0.8], ...
                          'FontSize', 9);
  
   % Botón para detener
   btn_detener = uicontrol('Parent', panel_control, ...
                          'Style', 'pushbutton', ...
                          'String', 'Detener', ...
                          'Position', [80 50 60 30], ...
                          'Callback', @detener_animacion, ...
                          'BackgroundColor', [0.9 0.8 0.8], ...
                          'FontSize', 9);
  
   % Gráfica del cuerpo humano con corazón
   cuerpo_ax = axes('Parent', fig, 'Position', [0.05 0.35 0.35 0.55]);
   axes(cuerpo_ax); % asegurarnos de que los surf se dibujen en este axes
   hold on;
  
   % Crear las partes del cuerpo humano (función retorna handles)
   cuerpo_parts = crear_forma_cuerpo();
  
   % Crear el corazón en su posición anatómica
   [X, Y, Z] = crear_forma_corazon();
   % Posicionar el corazón en el centro del pecho (ligeramente a la izquierda)
   % Ajustes anatómicos: pequeña escala y desplazamiento hacia la izquierda y hacia arriba del centro del tórax
   X = X * 0.22 - 0.15;  % Escalar y desplazar a la izquierda
   Y = Y * 0.22;
   Z = Z * 0.22 + 0.15;  % Altura en la parte superior del tórax
  
   % Crear surface plot del corazón
   h = surf(X, Y, Z, 'FaceColor', [0.8, 0.1, 0.1], ...
            'EdgeColor', 'none', ...
            'FaceLighting', 'gouraud', ...
            'AmbientStrength', 0.3, ...
            'DiffuseStrength', 0.8, ...
            'SpecularStrength', 0.5, ...
            'SpecularExponent', 25, ...
            'BackFaceLighting', 'lit');
  
   % Configuración del entorno 3D (en el axes del cuerpo)
   axis equal;
   axis vis3d;
   grid on;
   view(3);
   axis([-1.5 1.5 -1.0 1.0 -2.5 2.0]);
   title('Corazón Latiente 3D en Cuerpo Humano', 'FontSize', 11, 'FontWeight', 'bold');
   xlabel('Eje X (Lateral)');
   ylabel('Eje Y (Anterior-Posterior)');
   zlabel('Eje Z (Vertical)');
  
   % Añadir iluminación
   light('Position', [2 2 2], 'Style', 'infinite');
   light('Position', [-2 -2 2], 'Style', 'infinite');
   lighting gouraud;
  
   % Gráfica del ECG
   ecg_ax = axes('Parent', fig, 'Position', [0.45 0.35 0.5 0.55]);
  
   % Inicializar datos del ECG
   tiempo_ecg = linspace(0, 8, 2000);
   senal_ecg = zeros(size(tiempo_ecg));
  
   % Crear línea del ECG
   axes(ecg_ax); hold on;
   ecg_line = plot(tiempo_ecg, senal_ecg, 'LineWidth', 2);
  
   % Configurar la gráfica del ECG
   grid on;
   xlabel('Tiempo (s)', 'FontSize', 11, 'FontWeight', 'bold');
   ylabel('Amplitud (mV)', 'FontSize', 11, 'FontWeight', 'bold');
   title('ELECTROCARDIOGRAMA - Onda PQRST', 'FontSize', 12, 'FontWeight', 'bold');
   axis([0 8 -0.5 1.5]);
   set(gca, 'FontSize', 10, 'GridAlpha', 0.3);
  
   % Línea de base cero
   line([0 8], [0 0], 'Color', [0.5 0.5 0.5], 'LineStyle', ':', 'LineWidth', 1);
  
   % Línea vertical indicadora del tiempo actual
   tiempo_indicador = line([0 0], [-0.5 1.5], 'Color', 'r', 'LineWidth', 2.5, 'LineStyle', '-');
  
   % Etiquetas de las ondas del ECG
   text(0.4, 0.25, 'P', 'FontSize', 10, 'FontWeight', 'bold', 'Color', [0.6 0 0]);
   text(1.0, 1.2, 'R', 'FontSize', 10, 'FontWeight', 'bold', 'Color', [0.6 0 0]);
   text(1.8, 0.35, 'T', 'FontSize', 10, 'FontWeight', 'bold', 'Color', [0.6 0 0]);
  
   hold off;
  
   % Variable para controlar la animación
   animacion_activa = false;
  
   % Callback functions
   function actualizar_frecuencia(src, ~)
       frecuencia_lpm = round(get(src, 'Value'));
       set(texto_lpm, 'String', sprintf('%d LPM', frecuencia_lpm));
   end
  
   function iniciar_animacion(~, ~)
       if ~animacion_activa
           animacion_activa = true;
           set(btn_iniciar, 'String', 'Pausar', 'BackgroundColor', [0.9 0.9 0.7]);
           ejecutar_animacion();
       else
           animacion_activa = false;
           set(btn_iniciar, 'String', 'Reanudar', 'BackgroundColor', [0.8 0.9 0.8]);
       end
   end
  
   function detener_animacion(~, ~)
       animacion_activa = false;
       set(btn_iniciar, 'String', 'Iniciar', 'BackgroundColor', [0.8 0.9 0.8]);
      
       % Restaurar forma original del corazón en la posición anatómica
       [X0, Y0, Z0] = crear_forma_corazon(1);
       X0 = X0 * 0.22 - 0.15;
       Y0 = Y0 * 0.22;
       Z0 = Z0 * 0.22 + 0.15;
       set(h, 'XData', X0, 'YData', Y0, 'ZData', Z0);
       view(cuerpo_ax, 3);
      
       % Reiniciar el ECG
       senal_ecg(:) = 0;
       set(ecg_line, 'YData', senal_ecg);
       set(tiempo_indicador, 'XData', [0 0]);
   end
  
   function ejecutar_animacion()
       t_inicio = tic;
       frame = 0;
      
       while animacion_activa && ishandle(fig)
           frame = frame + 1;
           t_actual = toc(t_inicio);
          
           % Calcular el factor de latido
           frecuencia_hz = frecuencia_lpm / 60;
           periodo = 1 / frecuencia_hz;
           fase = mod(t_actual, periodo) / periodo;
          
           factor_latido = 1 + 0.20 * sin(2 * pi * frecuencia_hz * t_actual) .* ...
                          exp(-0.1 * mod(t_actual, periodo));
          
           % Actualizar la forma del corazón (misma transformación anatómica)
           [X_new, Y_new, Z_new] = crear_forma_corazon(factor_latido);
           X_new = X_new * 0.22 - 0.15;
           Y_new = Y_new * 0.22;
           Z_new = Z_new * 0.22 + 0.15;
           set(h, 'XData', X_new, 'YData', Y_new, 'ZData', Z_new);
          
           % Rotar ligeramente la vista alrededor del cuerpo
           view(cuerpo_ax, 20 + 5*sin(t_actual), 20 + 4*cos(0.7*t_actual));
          
           % Actualizar el ECG
           actualizar_ECG(t_actual, frecuencia_hz);
          
           % Actualizar indicador de tiempo en el ECG
           tiempo_visual = mod(t_actual, 8);
           set(tiempo_indicador, 'XData', [tiempo_visual tiempo_visual]);
          
           % Pausa para mantener el framerate
           pause(1/fps);
          
           if t_actual >= tiempo_total
               animacion_activa = false;
               set(btn_iniciar, 'String', 'Iniciar', 'BackgroundColor', [0.8 0.9 0.8]);
               break;
           end
       end
   end
  
   function actualizar_ECG(t_actual, frecuencia_hz)
       % Generar señal ECG con onda PQRST realista
       periodo = 1 / frecuencia_hz;
       fase = mod(t_actual, periodo);
      
       % Parámetros de las ondas del ECG
       t_p = 0.06 * periodo;
       t_qrs = 0.10 * periodo;
       t_t = 0.20 * periodo;
      
       % Actualizar el buffer del ECG
       senal_ecg = circshift(senal_ecg, -1);
      
       % Generar nueva muestra de ECG
       if fase < t_p
           fase_p = fase / t_p;
           senal_ecg(end) = 0.25 * exp(-40*(fase_p - 0.5).^2);
       elseif fase < t_p + t_qrs
           fase_qrs = (fase - t_p) / t_qrs;
           if fase_qrs < 0.15
               senal_ecg(end) = -0.15 * fase_qrs/0.15;
           elseif fase_qrs < 0.4
               senal_ecg(end) = 1.2 * (fase_qrs-0.15)/0.25;
           elseif fase_qrs < 0.7
               senal_ecg(end) = -0.4 * (fase_qrs-0.4)/0.3;
           else
               senal_ecg(end) = 0.1 * (1 - (fase_qrs-0.7)/0.3);
           end
       elseif fase < t_p + t_qrs + t_t
           fase_t = (fase - t_p - t_qrs) / t_t;
           senal_ecg(end) = 0.35 * exp(-6*(fase_t - 0.5).^2);
       else
           senal_ecg(end) = 0.02 * sin(2*pi*0.5*fase);
       end
      
       % Añadir ruido aleatorio
       ruido = 0.015 * randn;
       senal_ecg(end) = senal_ecg(end) + ruido;
      
       % Actualizar la gráfica del ECG
       set(ecg_line, 'YData', senal_ecg);
   end
end

function [X, Y, Z] = crear_forma_corazon(factor_escala)
   % Crear la forma paramétrica de un corazón
   if nargin < 1
       factor_escala = 1;
   end
  
   % Parámetros de la malla
   u = linspace(0, 2*pi, 60);
   v = linspace(0, pi, 30);
   [U, V] = meshgrid(u, v);
  
   % Ecuaciones paramétricas del corazón (forma estilizada)
   X = factor_escala * sin(U) .* sin(U) .* sin(V);
   Y = factor_escala * sin(U) .* cos(U) .* sin(V);
   Z = factor_escala * cos(V);
  
   % Ajustar la forma para que se parezca más a un corazón
   X = X .* (1.2 + 0.8 * cos(U));
   Y = Y .* (1.2 + 0.8 * cos(U));
   Z = Z .* (0.8 + 0.5 * sin(U));
end

function parts = crear_forma_cuerpo()
   % Crear una forma simplificada del cuerpo humano con posiciones anatómicas
   parts = struct();
  
   % Torso (cilindro elíptico), centrado en X=0, Y=0, Z en [-0.9, 0.9]
   [X_torso, Y_torso, Z_torso] = cylinder([0.8, 0.9, 0.8], 40);
   Z_torso = Z_torso * 1.8 - 0.9; % ahora va de -0.9 a +0.9 (altura del torso)
   parts.torso = surf(X_torso, Y_torso, Z_torso, ...
                     'FaceColor', [0.95, 0.78, 0.66], ...
                     'EdgeColor', 'none', ...
                     'FaceAlpha', 0.9);
  
   % Cabeza (esfera) - posicionada arriba del torso
   head_radius = 0.35;
   [X_cabeza, Y_cabeza, Z_cabeza] = sphere(30);
   X_cabeza = X_cabeza * head_radius;
   Y_cabeza = Y_cabeza * head_radius;
   % Colocar la cabeza justo encima de la parte superior del torso (top torso ~= +0.9)
   head_center_z = 0.9 + head_radius - 0.02; % pequeño solapamiento natural del cuello
   Z_cabeza = Z_cabeza * head_radius + head_center_z;
   parts.cabeza = surf(X_cabeza, Y_cabeza, Z_cabeza, ...
                      'FaceColor', [0.95, 0.78, 0.66], ...
                      'EdgeColor', 'none', ...
                      'FaceAlpha', 0.95);
  
   % Brazos (cilindros verticales al costado del torso, desde hombro hacia abajo)
   arm_radius_top = 0.14;
   arm_radius_bottom = 0.11;
   [X_brazo, Y_brazo, Z_brazo] = cylinder([arm_radius_top, arm_radius_bottom], 20);
   % Hacer brazos del largo aproximado del torso (de hombro ~+0.6 hasta cerca de -0.9)
   Z_brazo = Z_brazo * 1.6 - 0.6; % rango aproximado [ -0.6 .. +1.0 ] -> luego se ajusta
   % brazo derecho (colocado a la derecha lateral del torso)
   X_brazo_d = X_brazo + (0.9 + arm_radius_top); % fuera del torso
   parts.brazo_derecho = surf(X_brazo_d, Y_brazo, Z_brazo, ...
                             'FaceColor', [0.95, 0.78, 0.66], ...
                             'EdgeColor', 'none', ...
                             'FaceAlpha', 0.95);
   % brazo izquierdo
   X_brazo_i = X_brazo - (0.9 + arm_radius_top);
   parts.brazo_izquierdo = surf(X_brazo_i, Y_brazo, Z_brazo, ...
                               'FaceColor', [0.95, 0.78, 0.66], ...
                               'EdgeColor', 'none', ...
                               'FaceAlpha', 0.95);
  
   % Piernas (cilindros) - comienzan justo por debajo del torso y bajan
   leg_radius_top = 0.20;
   leg_radius_bottom = 0.15;
   [X_pierna, Y_pierna, Z_pierna] = cylinder([leg_radius_top, leg_radius_bottom], 24);
   % Colocar piernas para que su parte superior coincida con el fondo del torso (~ -0.9)
   % y se extiendan hacia abajo (longitud de pierna ~1.2)
   Z_pierna = Z_pierna * 1.2 - 2.1; % rango [-2.1 .. -0.9]
   % pierna derecha centrada un poco a la derecha del eje central
   X_pierna_d = X_pierna + 0.25;
   parts.pierna_derecha = surf(X_pierna_d, Y_pierna, Z_pierna, ...
                              'FaceColor', [0.95, 0.78, 0.66], ...
                              'EdgeColor', 'none', ...
                              'FaceAlpha', 0.95);
   % pierna izquierda
   X_pierna_i = X_pierna - 0.25;
   parts.pierna_izquierda = surf(X_pierna_i, Y_pierna, Z_pierna, ...
                                'FaceColor', [0.95, 0.78, 0.66], ...
                                'EdgeColor', 'none', ...
                                'FaceAlpha', 0.95);
end

% Ejecutar la simulación automáticamente al correr el script
corazon_latiente_3D_con_ECG_mejorado;
