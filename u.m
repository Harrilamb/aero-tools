% real term assumed to be in 4th position in quaternion
classdef u
    
   properties (Access = public, Constant = true)
      
       mu = 398600; % gravitational constant m3/s2
       earthR = 6371; % km
       
   end
   
   methods (Static)
       
       function [cross] = vect2cross(vect)
           cross=[0 -vect(3) vect(2); vect(3) 0 -vect(1); -vect(2) vect(1) 0];
       end
       
       function q = eul2q(euler)
        % euler in form (phi,theta,psi)
        phi = euler(1);
        theta = euler(2);
        psi = euler(3);
        % q1 = [cos(psi/2); 0; 0; sin(psi/2)];
        % q2 = [cos(theta/2); 0; sin(theta/2); 0];
        % q3 = [cos(phi/2); sin(phi/2); 0; 0];
        q = [ (cos(phi/2)*cos(theta/2)*cos(psi/2)) + (sin(phi/2)*sin(theta/2)*sin(psi/2));
              (sin(phi/2)*cos(theta/2)*cos(psi/2)) - (cos(phi/2)*sin(theta/2)*sin(psi/2));
              (cos(phi/2)*sin(theta/2)*cos(psi/2)) + (sin(phi/2)*cos(theta/2)*sin(psi/2));
              (cos(phi/2)*cos(theta/2)*sin(psi/2)) - (sin(phi/2)*sin(theta/2)*cos(psi/2))
        ];
       end
       
       function eul = quat2eul(q)
           % with eta as the first term
           eul = [ atan2(2*(q(1)*q(2)+q(3)*q(4)),1-2*(q(2)^2+q(3)^2));
                   asin(2*(q(1)*q(3)-q(4)*q(2)));
                   atan2(2*(q(1)*q(4)+q(2)*q(3)),1-2*(q(3)^2+q(4)^2))
           ];
       end
       
       function qout = quatMult(q1,q2)
           qout=(q1(4)*q2(4) - q1(1:3)'*q2(1:3))+q1(4)*q2(1:3)+q2(4)*q1(1:3)+vect2cross(q1(1:3))*q2(1:3);
       end
       
       function q4 = qswap(q1,currPos)
           if currPos==1
               q4 = [q1(2:4);q1(1)];
           elseif currPos==4
               q4 = [q1(4);q1(1:3)];
           elseif currPos==0
               qtest = q1;
               q4 = q1;
           end    
       end
       
       function qe = qerr(qc,q)
            % qe=(qc(4)*q(4) - qc(1:3)'*q(1:3))+qc(4)*q(1:3)+q(4)*qc(1:3)+u.vect2cross(qc(1:3))*q(1:3);
            qc = [qc(4) -qc(1) -qc(2) -qc(3)]';
            qe = qc*q';
       end
       
       function d = toDiag(v)
           c=zeros(size(v,1),size(v,1));
           for i=1:size(v,1)
              c(i,i)=v(i); 
           end
           d=c;
       end
       
       function cirVel = orbitalVelC(rad)
           earthMu =  1.327e20; % m3/s2
           cirVel = sqrt(earthMu/(rad+u.earthR));
       end

       function ellVel = orbitalVelE(rad,apo)
           earthMu =  1.327e20; % m3/s2
           ellVel = sqrt(earthMu*((2/rad)-(1/apo)));
       end
       
       function conv = ton2kg(ton)
           conv = ton*1000;
       end
       
   end
   
end