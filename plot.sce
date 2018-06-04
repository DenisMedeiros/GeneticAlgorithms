clear
//
[x,y]=meshgrid(-500:5:500,-500:5:500);
//
 z=-x.*sin(sqrt(abs(x)))-y.*sin(sqrt(abs(y)));
x=x/250;
y=y/250;
// r: Rosenbrock's function
 r=100*(y-x.^2).^2+(1-x).^2;
 r1=(y-x.^2).^2+(1-x).^2;
 rd=1+r1;
//
x1=25*x;
x2=25*y;
xs =-10:0.1:10;
ys =-10:0.1:10;
a=500;
b=0.1;
c=0.5*%pi;
//
F10=-a*exp(-b*sqrt((x1.^2+x2.^2)/2))-exp((cos(c*x1)+cos(c*x2))/2)+exp(1);
//
[n nx]=size(xs);
[n ny]=size(ys);
for i=1:nx
for j=1:ny
zsh(i,j)=0.5-((sin(sqrt(xs(i)^2+ys(j)^2)))^2-0.5)./(1+0.1*(xs(i)^2+ys(j)^2))^2;
end
end

//
Fobj=F10.*zsh//+a*cos(x1/30);
//
//surf(x1,x2,Fobj)
//
 w=r.*z;
 w2=z-r1;
 w6=w+w2;
x = x*250;
 y = y *250;
//
surf(x,y,w6);
