#########
##
## Constraint Selection Script for 2021_Bottino_Biserial
##
#########

#####
# 0. Loading Packages
#####

using PDBTools
using XCorrelation ; const XC = XCorrelation
using DelimitedFiles
using ProgressMeter

#####
# 1. Declaring Custom Functions
#####

## 1.1. Function to read a single sequence on a FASTA file

function readsingleFASTA(path :: String)
  sequence = filter(line -> !occursin(r"^>", line), readlines(open(path)))
  return(split(reduce(*, sequence), ""))
end

## 1.2. Function to read the alignment logs and build the consensus matrix

function read_alignlogs(alignlist :: Array{String,1})
  println(" Number of alignment logs: ", length(alignlist))
  println(" Reading alignment logs and computing consensus matrix ... ")
  dd = Int(length(alignlist))
  contact_matrix = Array{Float64}(undef, dd, dd)
  row = Array{Float64,1}
  @showprogress for i in 1:dd
    try
      line = DelimitedFiles.readdlm(alignlist[i], comments = true)[:, 3]
      row = convert(Array{Float64,1}, line)
      row = append!([1.] , row)
    catch
      row = 1.
    end
  contact_matrix[(i:dd), i] .= row
  contact_matrix[i, (i:dd)] .= row
  end
  return(contact_matrix)
end

## 1.3. Function to find the consensus model from the consensus matrix

function find_consensus_model(consensus_matrix)
  davies_scores = zeros(size(consensus_matrix)[1])
  for i in 1:(size(consensus_matrix)[1])
    davies_scores[i] = sum(consensus_matrix[i,:])/length(consensus_matrix[i,:])
  end
  consensus_index = findall(davies_scores .== maximum(davies_scores))
  return(consensus_index[1])
end

## 1.4. Function to compute the biserial correlation between contacts and model qualities

function cst_biserials(contact_matrix :: Array{Float64,2}, model_scores :: Array{Float64,1})
  bisvector = Array{Float64, 1}(undef, size(contact_matrix)[2])
  for cst in 1:(size(contact_matrix)[2])
    bisvector[cst] = XCorrelation.biserial_correlation(contact_matrix[:,cst], model_scores)
  end
  return(bisvector)
end

#####
# 2. Constraint selection script
#####

## 2.1. Read list of PDB files and obtain a list with full path names.

pdbdir = "./1C75_A_PRE00/pdb" # substitute with working directory of your models if not following the tutorial.
println(" PDB Directory: ", pdbdir)
pdblist = readdir(pdbdir)
pdblist = filter( x -> occursin(".pdb",x),pdblist)
@. pdblist = pdbdir*"/"*pdblist

# 2.2. Compute the ContactData Object with the structural data of the PDBs.

# selecting only CB atoms or CA of glycines. Refer to PDBTools documentation for customizing.
C = XC.contact_data(pdblist, lastpdb=nothing, minsep=1, tol = 0.0, reference = 8.0, selection="resname GLY and name CA or name CB")

# 2.3. Read the list of structural alignment logs as from @gscore/align_all.sh
aligndir = "./1C75_A_PRE00/alignlogs"
println(" Alignment logs Directory: ", aligndir)
alignlist = readdir(aligndir)
alignlist = filter( x -> occursin(".log",x),alignlist)
@. alignlist = aligndir*"/"*alignlist

# 2.4. Use the function to read the alignment logs, build a consensus matrix and find the consensus model,
#      storing the vector (consensus_vector) with model qualities with respect to this consensus model

consensus_matrix = read_alignlogs(alignlist)
consensus_model = find_consensus_model(consensus_matrix)
println("Consensus model index: "*string(consensus_model)) # Prints the consensus model index on the list.
consensus_vector = convert(Array{Float64, 1}, consensus_matrix[: , consensus_model]) # computes TM-score of all models against the conesnsus model.

# 2.5. Computing the point-biserial coefficients and building the constraint matrix

biserial_coefs = cst_biserials(C.ContactBin, consensus_vector)
constraint_matrix = [C.Contacts biserial_coefs]
constraint_matrix = constraint_matrix[ .!(isnan.(constraint_matrix[:, 3])), :] # Filters out the NaN values
constraint_matrix = constraint_matrix[sortperm(constraint_matrix[:, 3], rev=true), :] # Sorts by descending r_pb values

# 2.6. Writing the bisList file with the full list of non-NaN coefficients

open("bisList.dat", "w") do io
  writedlm(io, constraint_matrix, quotes=false)
end

######
# 3. Creating the constraint file for modeling
######

## 3.1. Reading the FASTA sequence to know the location of glycines

sequence = readsingleFASTA("./FIXED_INPUT/" * filter( x -> occursin(".fasta",x),readdir("FIXED_INPUT/"))[1])

## 3.2. Selecting the amount of constraints as the number of non-negative r_pb's # This was changec back to L constraints

constraint_amount = length(sequence)
selected_constraints = Array{String}(undef, constraint_amount )

## 3.3. Collecting Constraints on AtomPair format

for i in 1:constraint_amount

  resone = Int(constraint_matrix[i,1])
  restwo = Int(constraint_matrix[i,2])

  if ((sequence[resone] == "G") & (sequence[restwo] == "G"))
    selected_constraints[i] = "AtomPair CA "*string(resone)*" CA "*string(restwo)*" BOUNDED 3.500 8.000 1.0 BIS;"
  elseif ((sequence[resone] == "G") & (sequence[restwo] !== "G"))
    selected_constraints[i] = "AtomPair CA "*string(resone)*" CB "*string(restwo)*" BOUNDED 3.500 8.000 1.0 BIS;"
  elseif ((sequence[resone] !== "G") & (sequence[restwo] == "G"))
    selected_constraints[i] = "AtomPair CB "*string(resone)*" CA "*string(restwo)*" BOUNDED 3.500 8.000 1.0 BIS;"
  elseif ((sequence[resone] !== "G") & (sequence[restwo] !== "G"))
    selected_constraints[i] = "AtomPair CB "*string(resone)*" CB "*string(restwo)*" BOUNDED 3.500 8.000 1.0 BIS;"
  end

end

## 3.4. Writing constraint list file ("xl")

open("selected_constraints.cst", "w") do io
  writedlm(io, selected_constraints, quotes=false)
end
