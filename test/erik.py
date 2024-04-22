import sys;sys.setrecursionlimit(10**7)
n,k,*s=map(int,open(0).read().split())
g=[[]for _ in' '*n]
j=1
for i in s:g[i-1]+=[j];j+=1
def D(p,q):
    c=t=0
    for C in g[q]:a,b=D(p,C);t+=a;c+=b
    return(t+1,c)if t<p else(0,c+1)
l,h=1,n
while l<h:m=(l+h)//2;(l:=m+1)if D(m,0)[1]>k else (h:=m)
print(l)