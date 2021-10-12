% testpipefriction
clear
d=2;
eps=0.01;
Re1 = linspace(100,2000,20)
Re2 = linspace(2100,4000,20)
Re3 = linspace(4100,10000,60)
i=1;
for Re_i = Re1
   f1(i) = pipe_friction_factor(Re_i, d, eps)
   i=i+1
end
i=1;
for Re_i = Re2
   f2(i) = pipe_friction_factor(Re_i, d, eps)
   i=i+1
end
i=1;
for Re_i = Re3
   f3(i) = pipe_friction_factor(Re_i, d, eps)
   i=i+1
end
figure(100), clf
plot(Re1,f1,Re2,f2,Re3,f3,'Linewidth',5)
xlabel('Re')
ylabel('f')
axis([100 10000 0 0.12])