clc
clear 
close all

function corazon_latiente_3D_con_ECG_mejorado
   % Simulación de un corazón latiendo en 3D con visualización de ECG
   % Mejoras visuales: ECG estilo monitor (fondo negro, trazo verde nítido),
   % latido generado por plantilla P-QRS-T, y textos del panel en color negro.
  
   global h frecuencia_lpm tiempo_total fps ecg_ax ecg_line tiempo_ecg senal_ecg cuerpo_parts;
  
   % Valores iniciales
   frecuencia_lpm = 72; % latidos por minuto iniciales
   tiempo_total = 30;   % segundos de simulación total
   fps = 30;            % frames por segundo de la animación
   Fs = 250;            % frecuencia de muestreo para el ECG (Hz)
   ventana_ecg_s = 8;   % ventana visual del ECG en segundos
  
   % Preparar figura
   fig = figure('Name', 'Corazón Latiente 3D con Cuerpo Humano y ECG', ...
               'Position', [50, 50, 1400, 700], ...
               'Color', 'white', ...
               'NumberTitle', 'off');
  
   % Panel para controles (texto en negro para mayor legibilidad)
   panel_control = uipanel('Parent', fig, ...
                          'Title', 'Controles', ...
                          'Position', [0.82 0.05 0.16 0.25], ...
                          'BackgroundColor', [0.95 0.95 0.95], ...
                          'FontWeight', 'bold');
  
   % Texto slider
   uicontrol('Parent', panel_control, ...
            'Style', 'text', ...
            'String', 'Latidos por Minuto (LPM):', ...
            'Position', [10 120 140 20], ...
            'BackgroundColor', [0.95 0.95 0.95], ...
            'HorizontalAlignment', 'left', ...
            'FontSize', 9, ...
            'ForegroundColor', [0 0 0]);
  
   slider_lpm = uicontrol('Parent', panel_control, ...
                         'Style', 'slider', ...
                         'Min', 40, ...
                         'Max', 140, ...
                         'Value', frecuencia_lpm, ...
                         'Position', [10 90 130 20], ...
                         'Callback', @actualizar_frecuencia);
  
   texto_lpm = uicontrol('Parent', panel_control, ...
                        'Style', 'text', ...
                        'String', sprintf('%d LPM', frecuencia_lpm), ...
                        'Position', [150 90 40 20], ...
                        'BackgroundColor', [0.95 0.95 0.95], ...
                        'FontSize', 9, ...
                        'ForegroundColor', [0 0 0]);
  
   btn_iniciar = uicontrol('Parent', panel_control, ...
                          'Style', 'pushbutton', ...
                          'String', 'Iniciar', ...
                          'Position', [10 50 60 30], ...
                          'Callback', @iniciar_animacion, ...
                          'BackgroundColor', [0.8 0.9 0.8], ...
                          'FontSize', 9, ...
                          'ForegroundColor', [0 0 0]);
  
   btn_detener = uicontrol('Parent', panel_control, ...
                          'Style', 'pushbutton', ...
                          'String', 'Detener', ...
                          'Position', [80 50 60 30], ...
                          'Callback', @detener_animacion, ...
                          'BackgroundColor', [0.9 0.8 0.8], ...
                          'FontSize', 9, ...
                          'ForegroundColor', [0 0 0]);
  
   % --- Área 3D (cuerpo + corazón)
   cuerpo_ax = axes('Parent', fig, 'Position', [0.05 0.35 0.35 0.55]);
   axes(cuerpo_ax);
   hold on;
   cuerpo_parts = crear_forma_cuerpo();   % devuelve handles de las superficies
  
   % Corazón en posición anatómica (ligeramente a la izquierda, alto en tórax)
   [X, Y, Z] = crear_forma_corazon();
   X = X * 0.22 - 0.15;
   Y = Y * 0.22;
   Z = Z * 0.22 + 0.15;
   h = surf(X, Y, Z, 'FaceColor', [0.8, 0.08, 0.08], ...
            'EdgeColor', 'none', ...
            'FaceLighting', 'gouraud', ...
            'AmbientStrength', 0.3, ...
            'DiffuseStrength', 0.8, ...
            'SpecularStrength', 0.5, ...
            'SpecularExponent', 25, ...
            'BackFaceLighting', 'lit');
  
   axis equal;
   axis vis3d;
   grid on;
   view(3);
   axis([-1.5 1.5 -1.0 1.0 -2.5 2.0]);
   title('Corazón Latiente 3D en Cuerpo Humano', 'FontSize', 11, 'FontWeight', 'bold');
   xlabel('Eje X (Lateral)');
   ylabel('Eje Y (Anterior-Posterior)');
   zlabel('Eje Z (Vertical)');
   light('Position', [2 2 2], 'Style', 'infinite');
   light('Position', [-2 -2 2], 'Style', 'infinite');
   lighting gouraud;
  
   % --- Área ECG (estilo monitor)
   ecg_ax = axes('Parent', fig, 'Position', [0.45 0.35 0.5 0.55]);
   axes(ecg_ax); hold on;
  
   % Tiempo y buffer del ECG (ventana desplazable)
   Nbuf = ventana_ecg_s * Fs;
   tiempo_ecg = linspace(0, ventana_ecg_s, Nbuf);
   senal_ecg = zeros(1, Nbuf);
  
   % Configuración estética del eje ECG (fondo negro estilo monitor)
   set(ecg_ax, 'Color', 'k', ...
       'XColor', [0.75 0.75 0.75], ...
       'YColor', [0.75 0.75 0.75], ...
       'GridColor', [0 0.6 0], ...
       'GridAlpha', 0.25, ...
       'FontSize', 10);
   grid(ecg_ax, 'on');
  
   % Línea del ECG (verde brillante)
   ecg_line = plot(tiempo_ecg, senal_ecg, 'LineWidth', 2.5, 'Color', [0 1 0]);
  
   % Ajustes de etiquetas (visibles sobre fondo negro)
   xlabel('Tiempo (s)', 'FontSize', 11, 'FontWeight', 'bold', 'Color', [0.9 0.9 0.9]);
   ylabel('Amplitud (mV)', 'FontSize', 11, 'FontWeight', 'bold', 'Color', [0.9 0.9 0.9]);
   title('ELECTROCARDIOGRAMA - Onda PQRST', 'FontSize', 12, 'FontWeight', 'bold', 'Color', [0.85 0.85 0.85]);
   axis([0 ventana_ecg_s -0.6 1.6]);
  
   % Línea indicadora de tiempo actual
   tiempo_indicador = line([0 0], [-0.6 1.6], 'Color', 'r', 'LineWidth', 2.5, 'LineStyle', '-');
  
   % Texto fijo (P, R, T) opcional (sólo marcador visual)
   text(0.4, 0.25, 'P', 'FontSize', 10, 'FontWeight', 'bold', 'Color', [0.8 0.2 0.2]);
   text(1.0, 1.2, 'R', 'FontSize', 10, 'FontWeight', 'bold', 'Color', [0.8 0.2 0.2]);
   text(1.8, 0.35, 'T', 'FontSize', 10, 'FontWeight', 'bold', 'Color', [0.8 0.2 0.2]);
  
   hold off;
  
   % Variable control animación
   animacion_activa = false;
  
   % --- Callbacks ---
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
       % Restaurar corazón y ECG
       [X0, Y0, Z0] = crear_forma_corazon(1);
       X0 = X0 * 0.22 - 0.15;
       Y0 = Y0 * 0.22;
       Z0 = Z0 * 0.22 + 0.15;
       set(h, 'XData', X0, 'YData', Y0, 'ZData', Z0);
       senal_ecg(:) = 0;
       set(ecg_line, 'YData', senal_ecg);
       set(tiempo_indicador, 'XData', [0 0]);
   end
  
   % --- Animacion principal ---
   function ejecutar_animacion()
       t_inicio = tic;
       frame = 0;
       % parámetros para generación del ECG por fase
       while animacion_activa && ishandle(fig)
           frame = frame + 1;
           t_actual = toc(t_inicio);
  
           % latidos y periodo
           frecuencia_hz = frecuencia_lpm / 60;
           periodo = 1 / frecuencia_hz;   % segundos por latido
           % muestras a añadir por frame para respetar Fs
           muestras_por_frame = max(1, round(Fs / fps));
  
           % generar n nuevas muestras basadas en la plantilla por fase
           nuevos = zeros(1, muestras_por_frame);
           for k = 1:muestras_por_frame
               t_muestra = t_actual + (k-1)/Fs;
               fase = mod(t_muestra, periodo)/periodo; % en [0,1)
               nuevos(k) = plantilla_PQRST(fase);
           end
           % agregar baseline lento (ligera oscilación respiratoria) y ruido pequeño
           baseline = 0.02 * sin(2*pi*0.25*(t_actual + (0:muestras_por_frame-1)/Fs)); % 0.25 Hz
           ruido = 0.007 * randn(1, muestras_por_frame);
           nuevos = nuevos + baseline + ruido;
  
           % desplazar buffer (circshift negativo y rellenar al final)
           senal_ecg = [senal_ecg((muestras_por_frame+1):end) nuevos];
  
           % actualizar gráfico ECG
           set(ecg_line, 'YData', senal_ecg);
           tiempo_visual = mod(t_actual, ventana_ecg_s);
           set(tiempo_indicador, 'XData', [tiempo_visual tiempo_visual]);
  
           % actualizar latido del corazón (factor de latido más pronunciado si quieres)
           factor_latido = 1 + 0.16 * sin(2 * pi * frecuencia_hz * t_actual) .* exp(-0.08 * mod(t_actual, periodo));
           [X_new, Y_new, Z_new] = crear_forma_corazon(factor_latido);
           X_new = X_new * 0.22 - 0.15;
           Y_new = Y_new * 0.22;
           Z_new = Z_new * 0.22 + 0.15;
           set(h, 'XData', X_new, 'YData', Y_new, 'ZData', Z_new);
  
           % rotación ligera de la vista del cuerpo
           view(cuerpo_ax, 20 + 5*sin(t_actual), 20 + 4*cos(0.7*t_actual));
  
           pause(1/fps);
  
           if t_actual >= tiempo_total
               animacion_activa = false;
               set(btn_iniciar, 'String', 'Iniciar', 'BackgroundColor', [0.8 0.9 0.8]);
               break;
           end
       end
   end
end

% -----------------------
% Función plantilla P-QRS-T
% fase \in [0,1)
function y = plantilla_PQRST(phase)
   % Definición de ondas por gaussianas centradas en fases típicas
   % P: ~0.10, Q: ~0.26, R: ~0.285, S: ~0.32, T: ~0.55
   % Las anchuras están en fracción de latido
   p_amp = 0.12; p_center = 0.10; p_sigma = 0.03;
   q_amp = -0.06; q_center = 0.26; q_sigma = 0.01;
   r_amp = 1.00; r_center = 0.285; r_sigma = 0.008;
   s_amp = -0.20; s_center = 0.32; s_sigma = 0.01;
   t_amp = 0.30; t_center = 0.55; t_sigma = 0.04;
  
   % Gaussianas (usar wrap-around suave para fase cercana a 0/1)
   % calcular distancia circular
   dist = @(a,b) min(abs(a-b), 1-abs(a-b));
   y = p_amp * exp(-((dist(phase,p_center)).^2)/(2*p_sigma^2)) + ...
       q_amp * exp(-((dist(phase,q_center)).^2)/(2*q_sigma^2)) + ...
       r_amp * exp(-((dist(phase,r_center)).^2)/(2*r_sigma^2)) + ...
       s_amp * exp(-((dist(phase,s_center)).^2)/(2*s_sigma^2)) + ...
       t_amp * exp(-((dist(phase,t_center)).^2)/(2*t_sigma^2));
end

% -----------------------
% Forma paramétrica del corazón
function [X, Y, Z] = crear_forma_corazon(factor_escala)
   if nargin < 1
       factor_escala = 1;
   end
   u = linspace(0, 2*pi, 60);
   v = linspace(0, pi, 30);
   [U, V] = meshgrid(u, v);
   X = factor_escala * sin(U) .* sin(U) .* sin(V);
   Y = factor_escala * sin(U) .* cos(U) .* sin(V);
   Z = factor_escala * cos(V);
   X = X .* (1.2 + 0.8 * cos(U));
   Y = Y .* (1.2 + 0.8 * cos(U));
   Z = Z .* (0.8 + 0.5 * sin(U));
end

% -----------------------
% Construcción simplificada del cuerpo (torso, cabeza, brazos, piernas)
function parts = crear_forma_cuerpo()
   parts = struct();
   % Torso
   [X_torso, Y_torso, Z_torso] = cylinder([0.8, 0.9, 0.8], 40);
   Z_torso = Z_torso * 1.8 - 0.9;
   parts.torso = surf(X_torso, Y_torso, Z_torso, 'FaceColor', [0.95, 0.78, 0.66], 'EdgeColor', 'none', 'FaceAlpha', 0.9);
   % Cabeza
   head_radius = 0.35;
   [X_cabeza, Y_cabeza, Z_cabeza] = sphere(30);
   X_cabeza = X_cabeza * head_radius;
   Y_cabeza = Y_cabeza * head_radius;
   head_center_z = 0.9 + head_radius - 0.02;
   Z_cabeza = Z_cabeza * head_radius + head_center_z;
   parts.cabeza = surf(X_cabeza, Y_cabeza, Z_cabeza, 'FaceColor', [0.95, 0.78, 0.66], 'EdgeColor', 'none', 'FaceAlpha', 0.95);
   % Brazos
   arm_radius_top = 0.14; arm_radius_bottom = 0.11;
   [X_brazo, Y_brazo, Z_brazo] = cylinder([arm_radius_top, arm_radius_bottom], 20);
   Z_brazo = Z_brazo * 1.6 - 0.6;
   X_brazo_d = X_brazo + (0.9 + arm_radius_top);
   parts.brazo_derecho = surf(X_brazo_d, Y_brazo, Z_brazo, 'FaceColor', [0.95, 0.78, 0.66], 'EdgeColor', 'none', 'FaceAlpha', 0.95);
   X_brazo_i = X_brazo - (0.9 + arm_radius_top);
   parts.brazo_izquierdo = surf(X_brazo_i, Y_brazo, Z_brazo, 'FaceColor', [0.95, 0.78, 0.66], 'EdgeColor', 'none', 'FaceAlpha', 0.95);
   % Piernas
   leg_radius_top = 0.20; leg_radius_bottom = 0.15;
   [X_pierna, Y_pierna, Z_pierna] = cylinder([leg_radius_top, leg_radius_bottom], 24);
   Z_pierna = Z_pierna * 1.2 - 2.1;
   X_pierna_d = X_pierna + 0.25;
   parts.pierna_derecha = surf(X_pierna_d, Y_pierna, Z_pierna, 'FaceColor', [0.95, 0.78, 0.66], 'EdgeColor', 'none', 'FaceAlpha', 0.95);
   X_pierna_i = X_pierna - 0.25;
   parts.pierna_izquierda = surf(X_pierna_i, Y_pierna, Z_pierna, 'FaceColor', [0.95, 0.78, 0.66], 'EdgeColor', 'none', 'FaceAlpha', 0.95);
end

% Ejecutar al cargar el script
corazon_latiente_3D_con_ECG_mejorado;
