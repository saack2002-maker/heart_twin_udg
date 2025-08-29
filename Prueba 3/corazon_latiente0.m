clc
clear 
close all

function corazon_latiente_3D_con_ECG_mejorado
   % Simulación de un corazón latiendo en 3D con visualización de ECG mejorada y cuerpo humano
   % Autor: MATLAB Assistant
   % Fecha: 2024
  
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
   hold on;
  
   % Crear las partes del cuerpo humano
   cuerpo_parts = crear_forma_cuerpo();
  
   % Crear el corazón en su posición anatómica
   [X, Y, Z] = crear_forma_corazon();
   % Posicionar el corazón en el centro del pecho (ligeramente a la izquierda)
   X = X * 0.4 + 0.3;  % Escalar y desplazar
   Y = Y * 0.4;
   Z = Z * 0.4 + 0.2;  % Elevar ligeramente
  
   % Crear surface plot del corazón
   h = surf(X, Y, Z, 'FaceColor', [0.8, 0.1, 0.1], ...
            'EdgeColor', 'none', ...
            'FaceLighting', 'gouraud', ...
            'AmbientStrength', 0.3, ...
            'DiffuseStrength', 0.8, ...
            'SpecularStrength', 0.5, ...
            'SpecularExponent', 25, ...
            'BackFaceLighting', 'lit');
  
   % Configuración del entorno 3D
   axis equal;
   axis vis3d;
   grid on;
   view(3);
   axis([-2 2 -1.5 1.5 -1 3]);
   title('Corazón Latiente 3D en Cuerpo Humano', 'FontSize', 11, 'FontWeight', 'bold');
   xlabel('Eje X (Lateral)');
   ylabel('Eje Y (Anterior-Posterior)');
   zlabel('Eje Z (Vertical)');
  
   % Añadir iluminación
   light('Position', [1 1 1], 'Style', 'infinite');
   light('Position', [-1 -1 -1], 'Style', 'infinite');
   lighting gouraud;
  
   % Gráfica del ECG
   ecg_ax = axes('Parent', fig, 'Position', [0.45 0.35 0.5 0.55]);
  
   % Inicializar datos del ECG
   tiempo_ecg = linspace(0, 8, 2000);
   senal_ecg = zeros(size(tiempo_ecg));
  
   % Crear línea del ECG
   hold on;
   ecg_line = plot(tiempo_ecg, senal_ecg, 'b-', 'LineWidth', 2, 'Color', [0 0.4 0.8]);
  
   % Configurar la gráfica del ECG
   grid on;
   xlabel('Tiempo (s)', 'FontSize', 11, 'FontWeight', 'bold');
   ylabel('Amplitud (mV)', 'FontSize', 11, 'FontWeight', 'bold');
   title('ELECTROCARDIOGRAMA - Onda PQRST', 'FontSize', 12, 'FontWeight', 'bold', 'Color', [0 0.4 0.8]);
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
      
       % Restaurar forma original del corazón
       [X, Y, Z] = crear_forma_corazon(1);
       X = X * 0.4 + 0.3;
       Y = Y * 0.4;
       Z = Z * 0.4 + 0.2;
       set(h, 'XData', X, 'YData', Y, 'ZData', Z);
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
          
           factor_latido = 1 + 0.2 * sin(2 * pi * frecuencia_hz * t_actual) .* ...
                          exp(-0.1 * mod(t_actual, periodo));
          
           % Actualizar la forma del corazón
           [X_new, Y_new, Z_new] = crear_forma_corazon(factor_latido);
           X_new = X_new * 0.4 + 0.3;
           Y_new = Y_new * 0.4;
           Z_new = Z_new * 0.4 + 0.2;
           set(h, 'XData', X_new, 'YData', Y_new, 'ZData', Z_new);
          
           % Rotar ligeramente la vista
           view(cuerpo_ax, 20 + 5*sin(t_actual), 30);
          
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
   u = linspace(0, 2*pi, 50);
   v = linspace(0, pi, 25);
   [U, V] = meshgrid(u, v);
  
   % Ecuaciones paramétricas del corazón
   X = factor_escala * sin(U) .* sin(U) .* sin(V);
   Y = factor_escala * sin(U) .* cos(U) .* sin(V);
   Z = factor_escala * cos(V);
  
   % Ajustar la forma para que se parezca más a un corazón
   X = X .* (1.2 + 0.8 * cos(U));
   Y = Y .* (1.2 + 0.8 * cos(U));
   Z = Z .* (0.8 + 0.5 * sin(U));
end

function parts = crear_forma_cuerpo()
   % Crear una forma simplificada del cuerpo humano
   parts = struct();
  
   % Torso (cilindro elíptico)
   [X_torso, Y_torso, Z_torso] = cylinder([0.8, 0.9, 0.8], 30);
   Z_torso = Z_torso * 1.8 - 0.9;
   parts.torso = surf(X_torso, Y_torso, Z_torso, ...
                     'FaceColor', [0.9, 0.7, 0.6], ...
                     'EdgeColor', 'none', ...
                     'FaceAlpha', 0.7);
  
   % Cabeza (esfera)
   [X_cabeza, Y_cabeza, Z_cabeza] = sphere(20);
   X_cabeza = X_cabeza * 0.4;
   Y_cabeza = Y_cabeza * 0.4;
   Z_cabeza = Z_cabeza * 0.4 + 1.2;
   parts.cabeza = surf(X_cabeza, Y_cabeza, Z_cabeza, ...
                      'FaceColor', [0.9, 0.7, 0.6], ...
                      'EdgeColor', 'none', ...
                      'FaceAlpha', 0.7);
  
   % Brazos (cilindros)
   [X_brazo_d, Y_brazo_d, Z_brazo_d] = cylinder([0.15, 0.12], 20);
   Z_brazo_d = Z_brazo_d * 0.8 + 0.5;
   X_brazo_d = X_brazo_d + 0.9;
   parts.brazo_derecho = surf(X_brazo_d, Y_brazo_d, Z_brazo_d, ...
                             'FaceColor', [0.9, 0.7, 0.6], ...
                             'EdgeColor', 'none', ...
                             'FaceAlpha', 0.7);
  
   [X_brazo_i, Y_brazo_i, Z_brazo_i] = cylinder([0.15, 0.12], 20);
   Z_brazo_i = Z_brazo_i * 0.8 + 0.5;
   X_brazo_i = X_brazo_i - 0.9;
   parts.brazo_izquierdo = surf(X_brazo_i, Y_brazo_i, Z_brazo_i, ...
                               'FaceColor', [0.9, 0.7, 0.6], ...
                               'EdgeColor', 'none', ...
                               'FaceAlpha', 0.7);
  
   % Piernas (cilindros)
   [X_pierna_d, Y_pierna_d, Z_pierna_d] = cylinder([0.2, 0.15], 20);
   Z_pierna_d = Z_pierna_d * 1.2 - 1.1;
   X_pierna_d = X_pierna_d + 0.3;
   parts.pierna_derecha = surf(X_pierna_d, Y_pierna_d, Z_pierna_d, ...
                              'FaceColor', [0.9, 0.7, 0.6], ...
                              'EdgeColor', 'none', ...
                              'FaceAlpha', 0.7);
  
   [X_pierna_i, Y_pierna_i, Z_pierna_i] = cylinder([0.2, 0.15], 20);
   Z_pierna_i = Z_pierna_i * 1.2 - 1.1;
   X_pierna_i = X_pierna_i - 0.3;
   parts.pierna_izquierda = surf(X_pierna_i, Y_pierna_i, Z_pierna_i, ...
                                'FaceColor', [0.9, 0.7, 0.6], ...
                                'EdgeColor', 'none', ...
                                'FaceAlpha', 0.7);
end

% Ejecutar la simulación automáticamente al correr el script
corazon_latiente_3D_con_ECG_mejorado;