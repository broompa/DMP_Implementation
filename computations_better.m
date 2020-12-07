clf;
clc;
clear;
%% parameters
t0 = 0 ; 
tf = 20 ; 
td = 0.05; 
t = t0:td:tf;
a = 1;
y = sin(a*(t-3));
yd = diff(y)/td;
ydd = diff(yd)/td;
subplot(2,2,1)
plot(t,y,t(2:length(t)),yd,t(3:length(t)),ydd);
hold on;
plot(t,zeros(size(t)),'--b',t,ones(size(t)),'--g');

[f_new,K,D,g,x0,tau,s] = dmp(y,t0,tf,td,t);


%% functions

function [f_new,K,D,g,x0,tau,s] = dmp(x,t0,tf,td,t)
    tau = 1;
    xd = diff(x)/td;
    xdd = diff(xd)/td;
    v = [xd(1),xd]*tau; 
    vd = [xdd(1),xdd(1),xdd]*tau;
    K = 1; D = sqrt(4*K);
    g = x(length(x));
    x0 = x(1);
    
%     f_s = (-K*(g-x) + D*v + tau*vd)/(g-x0);
    

    alp_s = 0.2;
    s = exp(-alp_s*t/tau);
    
    f_s = (tau*vd + D*v)/K - (g-x) + (g-x0)*s;
    
    plot(t,s);
    legend('y','yd','ydd','0','1','s(t)');
    subplot(2,2,3);
    
    f_new = gaussian_basis(s,1,500,50,f_s);
    
end

function f_new2 = gaussian_basis(s,c,h,n,f_s)
    Cs = (1:n)*(c/n);
    Cs = ones(length(s),1)*Cs;
    sn = s'*ones(1,n);
    K = exp(-h.*(sn-Cs).^2);
    K1 = K;
    wi_lw = zeros(n,1);
    for i = 1:n
        qsi = diag(K1(:,i));
        
        wi_lw(i,1) = (s*qsi*f_s')/(s*qsi*s');
    end
    for i = 1:length(s)
        K(i,:) = K(i,:)*s(i)/sum(K(i,:));
    end
    f_new1 = K*wi_lw;
    
    wi = K'*K\K'*f_s';
    f_new2 = K*wi;
    
    hold on;
    subplot(2,2,2)
    plot(s,K1);
        
    subplot(2,2,3)
    plot(s,f_s);
    plot(s,f_new1);
    plot(s,f_new2);
    legend('f_s','f_{new1}','f_{new2}');
    
    
end