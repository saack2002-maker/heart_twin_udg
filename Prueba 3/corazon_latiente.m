clc
close all
clear 


function corazon_latiente_3D_con_ECG_mejorado
   % Simulación de un corazón latiendo en 3D con visualización de ECG mejorada
   % Autor: MATLAB Assistant
   % Fecha: 2024
  
   % Variables globales para la animación
   global h frecuencia_lpm tiempo_total fps ecg_ax ecg_line tiempo_ecg senal_ecg;
  
   % Valores iniciales
   frecuencia_lpm = 72; % latidos por minuto iniciales
   tiempo_total = 30; % segundos
   fps = 30; % frames por segundo
  
   % Configuración de la figura principal
   fig = figure('Name', 'Corazón Latiente 3D con ECG Mejorado', ...
               'Position', [50, 50, 1400, 700], ... % Ventana más ancha
               'Color', 'white', ...
               'NumberTitle', 'off');
  
   % Panel para controles (posición ajustada)
   panel_control = uipanel('Parent', fig, ...
                          'Title', 'Controles', ...
                          'Position', [0.82 0.05 0.16 0.25], ... % Panel más estrecho
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
  
   % Gráfica del corazón en 3D (más pequeña y a la izquierda)
   corazon_ax = axes('Parent', fig, 'Position', [0.05 0.35 0.35 0.55]); % Reducido tamaño
   [X, Y, Z] = crear_forma_corazon();
  
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
   axis([-3 3 -3 3 -2 2]);
   title('Corazón Latiente 3D', 'FontSize', 11, 'FontWeight', 'bold');
   xlabel('Eje X');
   ylabel('Eje Y');
   zlabel('Eje Z');
  
   % Añadir iluminación al corazón
   light('Position', [1 1 1], 'Style', 'infinite');
   light('Position', [-1 -1 -1], 'Style', 'infinite');
   lighting gouraud;
  
   % Gráfica del ECG (más ancha y horizontal, a la derecha)
   ecg_ax = axes('Parent', fig, 'Position', [0.45 0.35 0.5 0.55]); % Más ancha
  
   % Inicializar datos del ECG - ventana más larga para mejor visualización
   tiempo_ecg = linspace(0, 8, 2000); % 8 segundos de visualización
   senal_ecg = zeros(size(tiempo_ecg)); % Señal inicial
  
   % Crear línea del ECG con mejor visibilidad
   hold on;
   ecg_line = plot(tiempo_ecg, senal_ecg, 'b-', 'LineWidth', 2, 'Color', [0 0.4 0.8]);
  
   % Configurar la gráfica del ECG para mejor visualización
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
       set(h, 'XData', X, 'YData', Y, 'ZData', Z);
       view(corazon_ax, 3);
      
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
          
           % Calcular el factor de latido basado en la frecuencia actual
           frecuencia_hz = frecuencia_lpm / 60; % Convertir a Hz
           periodo = 1 / frecuencia_hz;
           fase = mod(t_actual, periodo) / periodo;
          
           factor_latido = 1 + 0.2 * sin(2 * pi * frecuencia_hz * t_actual) .* ...
                          exp(-0.1 * mod(t_actual, periodo));
          
           % Actualizar la forma del corazón
           [X_new, Y_new, Z_new] = crear_forma_corazon(factor_latido);
           set(h, 'XData', X_new, 'YData', Y_new, 'ZData', Z_new);
          
           % Rotar ligeramente la vista del corazón
           view(corazon_ax, 20 + 5*sin(t_actual), 30);
          
           % Actualizar el ECG
           actualizar_ECG(t_actual, frecuencia_hz);
          
           % Actualizar indicador de tiempo en el ECG
           tiempo_visual = mod(t_actual, 8); % Mostrar últimos 8 segundos
           set(tiempo_indicador, 'XData', [tiempo_visual tiempo_visual]);
          
           % Pausa para mantener el framerate
           pause(1/fps);
          
           % Verificar si se ha alcanzado el tiempo máximo
           if t_actual >= tiempo_total
               animacion_activa = false;
               set(btn_iniciar, 'String', 'Iniciar', 'BackgroundColor', [0.8 0.9 0.8]);
               break;
           end
       end
   end
  
   function actualizar_ECG(t_actual, frecuencia_hz)
       % Generar señal ECG con onda PQRST realista mejorada
       periodo = 1 / frecuencia_hz;
       fase = mod(t_actual, periodo);
      
       % Parámetros de las ondas del ECG (en segundos relativos al periodo)
       t_p = 0.06 * periodo;   % Onda P
       t_qrs = 0.10 * periodo; % Complejo QRS
       t_t = 0.20 * periodo;   % Onda T
      
       % Actualizar el buffer del ECG (desplazamiento)
       senal_ecg = circshift(senal_ecg, -1);
      
       % Generar nueva muestra de ECG con mejor definición
       if fase < t_p
           % Onda P (pequeña elevación positiva más suave)
           fase_p = fase / t_p;
           senal_ecg(end) = 0.25 * exp(-40*(fase_p - 0.5).^2);
       elseif fase < t_p + t_qrs
           % Complejo QRS (más definido)
           fase_qrs = (fase - t_p) / t_qrs;
           if fase_qrs < 0.15
               % Onda Q (pequeña negativa)
               senal_ecg(end) = -0.15 * fase_qrs/0.15;
           elseif fase_qrs < 0.4
               % Onda R (alta positiva)
               senal_ecg(end) = 1.2 * (fase_qrs-0.15)/0.25;
           elseif fase_qrs < 0.7
               % Onda S (negativa después de R)
               senal_ecg(end) = -0.4 * (fase_qrs-0.4)/0.3;
           else
               % Transición a línea base
               senal_ecg(end) = 0.1 * (1 - (fase_qrs-0.7)/0.3);
           end
       elseif fase < t_p + t_qrs + t_t
           % Onda T (más suave y realista)
           fase_t = (fase - t_p - t_qrs) / t_t;
           senal_ecg(end) = 0.35 * exp(-6*(fase_t - 0.5).^2);
       else
           % Línea base con pequeña variación
           senal_ecg(end) = 0.02 * sin(2*pi*0.5*fase);
       end
      
       % Añadir ruido aleatorio suave para mayor realismo
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
% Ejecutar la simulación automáticamente al correr el script
corazon_latiente_3D_con_ECG_mejorado;
