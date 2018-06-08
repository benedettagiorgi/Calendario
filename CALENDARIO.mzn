int: num_aule;
int: num_giorni;
int: num_ore;
int: num_esami;
int: num_stud;
set of int: pausa_pranzo={5,6};
array[1..num_aule] of int: capienza;
array[1..num_esami] of int: durata;
array[1..num_stud, 1..num_esami] of int: prenot;

array[1..num_ore,1..num_aule] of var 0..num_esami: orario;
array[1..num_esami] of var 1..num_aule: aule_esami;
array[1..num_esami] of var 1..num_ore: inizio_esami;
array[1..num_esami] of var 1..num_giorni :xdays;



constraint 
forall(i in 1..num_esami, j in 1..num_aule, k in 1..num_ore)
(if capienza[j] <= sum([bool2int(prenot[s,i]>0) | s in 1..num_stud]) 
    then orario[k,j] != i
    else true
    endif
);


constraint 
forall( i in 1..num_ore, j in 1..num_aule)
(if i mod 10 in pausa_pranzo 
   then  orario[i,j]=0
   else true
   endif
);



constraint
forall(s in 1..num_stud) (
  forall(e, e2 in 1..num_esami where e!=e2) (
     xdays[e]= 1+ ((inizio_esami[e] -1) div 10)
     /\ forall(k in 0..durata[e]-1)
          (orario[inizio_esami[e] + k,aule_esami[e]] = e )
     /\
     if (prenot[s,e] == prenot[s, e2] /\  prenot[s, e2]==1)
           then xdays[e] != xdays[e2]
           else true
           endif
     
   )

);



constraint
forall(i in 1..num_esami)
(exists(j in 1..num_aule) 
   (aule_esami[i]=j 
   /\   
   forall(k in 0..durata[i]-1)
    (orario[inizio_esami[i] + k, j]= i)
    )
)
/\
sum([bool2int(orario[i,j]>0) | i in 1..num_ore, j in 1..num_aule])= sum(durata);



constraint
   forall(e in 1..num_esami) (
        not(exists(t in 1..durata[e]-1) (
           (inizio_esami[e]+t-1) mod 10 > (inizio_esami[e]+t) mod 10
        ))
   )
 ;
 

 

solve satisfy;


output 
["\n" ++ "CALENDARIO :" ++ "\n"]
++
[
   if t mod 10 = 1 /\ r = 1 then
      "\n\n\nGIORNO " ++ show(d) ++ " \n "
   else  "" endif ++
   if r=1 then "\n" else " " endif ++
      show(orario[t,r])
| d in 1..num_giorni, t in 1+(d-1)*10..(num_ore div num_giorni)*d, r in 1..num_aule,
]

++[ "\n \n"]++

[ "GIORNI_ESAMI:  ", show(xdays), "\n",  
"AULE_ESAMI:  ", show(aule_esami), "\n",
"INIZIO_ESAMI:  ", show(inizio_esami), "\n",
];


