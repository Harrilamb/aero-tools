classdef optic < matlab.System
    % Optics Object - For all your visual desires
    %
    % Contains equations for designing optics
    % Refrences at end

    % Public, tunable properties
    properties (Access = public, Constant = true)
        planckConst = 6.6262e-34; % J; h
        lightVel = 2.9979e8; % m/s; c
        boltzmann = 1.3806e-23; % J/K; k
        stefanConst = 5.66961e-8; % W/m^2*K^4
        wienConst = 2898; % um*K
    end

    properties (Access=public)
        absorb = 0;
        transmit = 1;
        reflect = 0;
    end
    
    properties(DiscreteState)

    end

    % Pre-computed constants
    properties(Access = private)

    end

    methods(Static)
        
        % TODO: Attenuation Equation/Model, 2.3 Principle Equations, 2.6.3
        % Stop-Shift Equations, 3.1.2 Index of Refraction, 5.1 Zoom Lenses
        
        % Planck's Law Equation
        function spectralRad = plancks(wavelength,temperature)
            % wavelength: Input linspace of wavelengths being considered in
            % meters
            % temperature: Input array of temperatures interested in 
            LofLambda = zeros(max(size(temperature)),max(size(wavelength)));
            for i=1:max(size(temperature))
                temp = temperature(i);
                LofLambda(i,:) = ((2*o.planckConst*o.lightVel^2)./(wavelength.^5)).*(1./(exp((o.planckConst*o.lightVel)./(wavelength*o.boltzmann*temp))-1)); % W/m^3*sr
            end
            spectralRad = LofLambda;
        end
        
        % Stefan-Boltzmann Law Equation
        function powerDens = stefan(emissivity,temperature)
           % emissivity: Input emissivity of material
           % temperature: Input temperature of material in K
           powerDens = emissivity*o.stefanConst*temperature^4; % W/m^2
        end
        
        % Wien Displacement Law Equation
        function peakWave = wiens(temperature)
           % temperature: Input temperature in K
           peakWave = o.wienConst/temperature;
        end
        
        % Lens Transmission Equation
        function atr = lensTransmit(obj,a,t,r)
        % obj: Input name of the instance of this object
        % a: Input absorptance, or NaN if unknown
        % t: Input transmittance, or NaN if unknown
        % r: Input reflectance, or NaN if unknown
            if isnan(a)
                a=1-t-r;
            elseif isnan(t)
                t=1-a-r;
            elseif isnan(r)
                r=1-a-t;
            end
            obj.absorb = a; obj.transmit = t; obj.reflect = r;
            atr='Object Updated';
        end
        
        % Transmission Equation
        function t = transmittance(knowR,inp)
        % knowR: Boolean if you know reflectance    
        % inp: Input is a different array based on knowR 
        % If TRUE - 1st term of input is absorption coefficient
        % 2nd term of input is distance traveled through optical element
        % If FALSE - 1st term of input is reflectance
        % 2nd term is number of surfaces
            if knowR
                r = inp(1);
                m = inp(2);
                t = (1-r)^m
            else
                absCoeff = inp(1);
                dist = inp(2);
                t = exp(-absCoeff*dist);
            end
        end
        
        % Reflection Equation
        function r = reflectance(n)
        % n: Input index of refraction of optical material
            r = ((n-1)^2/(n+1)^2);
        end
        
        % Snell's Law
        function outAng = snell(inAng,mat)
            % inAng: Input incoming angle
            % mat: Input array of materials, [ 1st, 2nd ]
            n1 = mat(1);
            n2 = mat(2);
            outAng = asin(n1*sin(inAng)/n2);
        end
        
        % Airy Disk Diameter Equation
        % Find diameter of image disk on FPA (usually beta)
        function diam = airy(wavelength,fnum)
           % wavelength: Input wavelength
           % fnum: Input f-number, ratio of focal-length/aperture
           diam = 2.4*wavelength*fnum;
        end
        
        % Focal Length Equation
        function [focalL,lensPow] = focal(objDist,imgDist)
           % objDist: Input distance to object (negative) from lens
           % imgDist: Input distance to image (positive) from lens
           focalL = 1/((1/imgDist)-(1/objDist));
           lensPow = 1/focalL;
        end
        
        % Telescope Magnification
        function magnify = telescopeMag(known,inp)
            % known: Input what values about the object and image are known
            % inp: Input array of known values [ object, image ]
            if strcmp('focal',known)
               magnify = -inp(1)/inp(2);
            elseif strcmp('diam',known) 
               magnify = inp(1)/inp(2);
            elseif strcmp('angle',known)
               magnify = tan(inp(1))/tan(inp(2));
            end
        end
        
        % Achromatism Equations
        % primAchromat: Output primary achromatism's longitudinal chromatic
        % aberration
        % secSpect: Output second spectrum's longitudinal chromatic
        % aberration
        function [primAchromat, secSpect] = achromatism(refractInd,focal)
           % refractInd: Input array of refractive indeces of the chosen
           % thin lenses in this form [ nsa, nma, nla ; nsb, nmb, nlb ]
           % where s,m, and l signify short, mid, and long wavelength
           % indices of refraction and a and b are for the first and second
           % lens.
           % focal: Input focal length
           ri = refractInd;
           Va = (ri(1,2)-1)/(ri(1,1)-ri(1,3));
           Vb = (ri(2,2)-1)/(ri(2,1)-ri(2,3));
           fa = focal*((Va-Vb)/Va);
           fb = ((Vb-Va)/Vb);
           phia = 1/fa;
           phib = 1/fb;
           primAchromat = -(focal^2)*((phia/Va)+(phib/Vb));
           Pa = ((ri(1,1)-ri(1,2))/(ri(1,1)-ri(1,3)));
           Pb = ((ri(2,1)-ri(2,2))/(ri(2,1)-ri(2,3)));
           secSpect = -focal*((Pa-Pb)/(Va-Vb));
        end
        
        % Spherical Aberration
        function angularBeta = sphericalAbb(n,fNum)
           % n: Input refractive index
           % fNum: Input f-number
           angularBeta = ((n*(4*n-1))/(128*(n-1)^2*(n+2)*(fNum^3))); 
        end
        
        % Lens Power
        function power = lensPow(n,c)
           % n: Input index of refraction
           % c: Input curvature of lens, up to two lenses in the form 
           % [c1 c2]
           if max(size(c))>1
               power = (n-1)*(c(1)-c(2));
           else
               power = (n-1)*(c(1)-1);
           end
        end
        
        
        
    end
    
    methods(Access = protected)
        function setupImpl(obj)
            % Perform one-time calculations, such as computing constants
        end

        function y = stepImpl(obj,u)
            % Implement algorithm. Calculate y as a function of input u and
            % discrete states.
            y = u;
        end

        function resetImpl(obj)
            % Initialize / reset discrete-state properties
        end
    end
    
    %% References
    
    % Infrared Optics and Zoom Lenses, 2nd Edition, Allen Mann
end
