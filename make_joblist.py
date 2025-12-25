sint    = [0.35,0.7]
tanbeta = [3,5,10,15,20,25,30,35,40,50]
mass37  = [100,200,300,400,500,600,700,800,900,1000,1100,1200,1500]
mass55  = [10,50,100,200,300,400,500,600,700,800,900,1000,1100,1200,1500]
jobid = 0
with open("joblist.txt", "w") as f:
    for st in sint:
        for tb in tanbeta:
            for m37 in mass37:
                for m55 in mass55:
                    f.write(f"{st} {tb} {m37} {m55}\n")
                    jobid += 1

print("Total jobs:", jobid)
