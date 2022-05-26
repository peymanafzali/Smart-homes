sets
h  set of timeslots  /1*8/
i  set of appliances /i1*i2/
k  set of households /k1*k2/
s  set of price scenarios /s1*s5/
r  set of renewable production scenarios /r1*r5/
u /i2/
alias(z,h)
alias(v,h)
alias(x,h)
;

parameters

HH(h)
/
1 1
2 2
3 3
4 4
5 5
6 6
7 7
8 8
/

IE(k)  initial storage energy level
/
k1  3
k2  5
/

E(k)  storage efficiency
/
k1 0.8
k2 0.9
/


SD(k)  self-discharging coefficient of the storage
/
k1 0.01
k2 0.01
/
;

table GP(h,s)  grid energy price
   s1      s2      s3      s4      s5
1  0.7     0.6     0.8     0.7     0.5
2  1       1.3     1.1     0.9     1
3  1.2     1.2     1.3     1.4     1.3
4  1.5     1.2     1.4     1.3     1.2
5  2       1.8     1.9     2       2.1
6  1.7     1.8     1.5     1.6     1.7
7  1.5     1.6     1.6     1.5     1.4
8  0.5     0.5     0.4     0.3     0.6
;

table P(k,i)  power consumption of an appliance per timeslot
     i1     i2
K1   1      4
K2   3      2
;
table RQ(k,r,h)  amount of generated renewable energy

       1   2   3   4   5   6   7   8
k1.r1  0   0   0   2   1   2   0   0
k1.r2  0   0   0  1.9 1.1  2   0   0
k1.r3  0   0   0  1.8 1.2 1.9  0   0
k1.r4  0   0   0   2  0.9 2.1  0   0
k1.r5  0   0   0  2.1  1  1.8  0   0
k2.r1  1   2   0   0  0.9  1   0   2
k2.r2 1.1 2.1  0   0  0.8  1   0   2.1
k2.r3 0.9 1.9  0   0   1  1.1  0   2
k2.r4 1.2  2   0   0  1.2  1   0   2.2
k2.r5  1  2.2  0   0  0.9 0.9  0   1.9
;

table t(k,i)  duration of the running time of an appliance

    i1   i2
k1  5    2
k2  3    4
;

table d(k,i)  disutility factor of an appliance

      i1     i2
K1    0.01   0.01
K2    0.01   0.01
;
table rt(k,i,h) Reservation time of an appliance which represents the time when the scheduler gets a request to start a specific appliance
         1   2   3   4   5   6   7   8
k1.i1    1   0   0   0   0   0   0   0
k1.i2    1   0   0   0   0   0   0   0
k2.i1    1   0   0   0   0   0   0   0
k2.i2    1   0   0   0   0   0   0   0
;

variables
Z_cost
y(s,r)
Cnotrade(k,s,r)  total cost of the k-th household without trading
CE(k,s,r) Cost of energy from grid
CD(k) Cost of Disutility
RH(k,i) end time of the appliance if it has been started immediately after reservation
DS(k,h,s,r) energy demand or supply of a household
;

positive variables
SP(k)
GE(k,h,s,r)  energy drawn from the grid
RE(k,h,r)  energy used from the renewable source
SE(k,h,s,r)  energy level of storage
ECH(k,h,s,r) charged energy
EDCH(k,h,s,r) discharge energy
Expected_cost
eta(s,r)
VAR
CVAR
;

binary variables
SO(k,i,h)  appliances operation time(S=1 means the appliance is in operation)
US(k,i,h)  start time of an uninterruptible appliance(US=1 represents the timeslot when an uninterruptible appliance starts its operation)
;
integer variable
Te(k,i)  end time of an appliance operation
;



scalars
N  number of timeslots in the scheduling time horizon /8/
zeta_s  /0.2/
zeta_pv /0.2/
alpha /0.95/
beta /0.4/
;
GE.up(k,h,s,r)=20;
SE.up(k,h,s,r)=5;
SE.lo(k,h,s,r)=3;
RE.lo(k,h,r)=0;
SP.up('k1')=1;
SP.up('k2')=2;
SP.lo('k1')=0;
SP.lo('k2')=0;
ECH.up('k1',h,s,r)=1;
ECH.up('k2',h,s,r)=2;
EDCH.up('k1',h,s,r)=1;
EDCH.up('k2',h,s,r)=2;
ECH.LO('k1',h,s,r)=0;
ECH.LO('k2',h,s,r)=0;
EDCH.LO('k1',h,s,r)=0;
EDCH.LO('k2',h,s,r)=0;
Te.up(k,i)=8;

Equations
OBJ
Eq1
Eq1a
Eq1b
Eq1c
Eq3
Eq4
Eq5
Eq5a
Eq5b
Eq8
Eq9
Eq10
Eq11
Eq13a
Eq13a1
Eq13b
Eq13b1
Eq13b2
Eq13b3
Eq14a
Eq14b
Eq16
CVAR_eq
Z_cost_eq
eq_var
eq_eta
Expected_cost_eq
;

CVAR_eq.. CVAR=e=VAR-(1/(1-alpha))*sum((s,r),zeta_s*zeta_pv*eta(s,r));
Z_cost_eq.. Z_cost=e=sum((s,r),(1-beta)*y(s,r)-beta*CVAR);
eq_var(s,r).. VAR-y(s,r)=l=eta(s,r);
eq_eta(s,r).. eta(s,r)=g=0;
Expected_cost_eq.. Expected_cost=e=sum((s,r),y(s,r)*zeta_s*zeta_pv);

OBJ(s,r).. y(s,r)=e=sum(k,Cnotrade(k,s,r));
Eq1(k,s,r) .. Cnotrade(k,s,r)=e=CE(k,s,r)+CD(k);
Eq1a(k,s,r) .. CE(k,s,r)=e=sum(h,GP(h,s)*GE(k,h,s,r));
Eq1b(k) ..CD(k)=e=sum(i,d(k,i)*(Te(k,i)-(RH(k,i))));
Eq1c(k,i) .. RH(k,i)=e=sum(h,rt(k,i,h)*HH(h))+t(k,i)-1;
Eq3(k,h,s,r) .. sum(i,SO(k,i,h)*P(k,i))+ECH(k,h,s,r)=e=GE(k,h,s,r)+RE(k,h,r)+EDCH(k,h,s,r);
Eq4(k,"1",s,r) .. SE(k,"1",s,r)=e=IE(k)*(1-SD(k))+ECH(k,"1",s,r)-EDCH(k,"1",s,r);
Eq5(k,h,s,r)$(ord(h)>1) .. SE(k,h,s,r)=e=(SE(k,h-1,s,r)*(1-SD(k)))+ECH(k,h,s,r)-EDCH(k,h,s,r);
Eq5a(k,h,s,r) .. ECH(k,h,s,r)=l=SP(k)*E(k);
Eq5b(k,h,s,r) .. EDCH(k,h,s,r)=l=SP(k)/E(k);
Eq8(k,i) .. sum(h,SO(k,i,h))=e=t(k,i);
Eq9(k,h,r) .. RE(k,h,r)=l=RQ(k,r,h);
Eq10(k,i) .. sum(h,SO(k,i,h))=e=sum(x$(ord(x)>=sum(v,rt(k,i,v)*hh(v)) and ord(x)<=8),SO(k,i,x));
Eq11(k,i,h) .. SO(k,i,h)*HH(h)=l=Te(k,i);
Eq13a("k1",u,h)$(ord(h)>=1 and ord(h)<=7) .. SO("k1","i2",h)=g=US("k1","i2",h);
Eq13a1("k1",u,h+1)$(ord(h)>=1 and ord(h)<=7) .. SO("k1","i2",h+1)-1=g=-1*(1-US("k1","i2",h));
Eq13b("k2",u,h)$(ord(h)>=1 and ord(h)<=5) .. SO("k2","i2",h)=g=US("k2","i2",h);
Eq13b1("k2",u,h+1)$(ord(h)>=1 and ord(h)<=5) .. SO("k2","i2",h+1)-1=g=-1*(1-US("k2","i2",h));
Eq13b2("k2",u,h+2)$(ord(h)>=1 and ord(h)<=5) .. SO("k2","i2",h+2)-1=g=-1*(1-US("k2","i2",h));
Eq13b3("k2",u,h+3)$(ord(h)>=1 and ord(h)<=5) .. SO("k2","i2",h+3)-1=g=-1*(1-US("k2","i2",h));
Eq14a("k1",u) .. sum(h$(ord(h)>=1 and ord(h)<=7),US("k1","i2",h))=e=1;
Eq14b("k2",u) .. sum(h$(ord(h)>=1 and ord(h)<=5),US("k2","i2",h))=e=1;
Eq16(k,h,s,r) .. DS(k,h,s,r)=e=sum(i,SO(k,i,h)*P(k,i))-RQ(k,r,h)+ECH(k,h,s,r)-EDCH(k,h,s,r);



Model  optimizationmodule /all/;
option MINLP=COUENNE;
Solve  optimizationmodule using  minlp  minimizing Z_cost;
display Expected_cost.l,y.l,cnotrade.l,CVAR.l,CE.l,SO.l,RE.l,SE.l,ECH.l,EDCH.l,SP.l,GE.l,DS.l,GE.L,US.l,CD.l;

execute_unload 'D:\UCout.gdx',Expected_cost,y,cnotrade,CVAR,CE,SO,RE,SE,ECH,EDCH,SP,GE,DS,GE,US,CD,GP,P,RQ,t,d,rt;
execute 'gdxviewer.exe i=D:\UCout.gdx';
