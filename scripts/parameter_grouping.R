#Read parameters csv
params <- read.csv("../output/IMPC_parameters.csv", stringsAsFactors = FALSE)


#Identify parameter names for groups using keywords
category_keywords <- list(
  brain = c(
    "brain", "cortex", "cerebell", "hippocamp", "olfactory",
    "pituitar", "mening", "axon", "neuron", "neuro", "ganglion",
    "thalamus", "midbrain", "hindbrain", "spinal", "nervous",
    "trigeminal", "myelin", "encephal", "cranial nerve", "basal ganglia"
  ),
  
  weight = c(
    "weight", "body_weight", "mass", "growth", "body size",
    "length", "crown-rump", "crown rump", "bmi", "lean mass",
    "fat mass", "gravi", "scale"
  ),
  
  images = c(
    "image", "scan", "pixel", "photo", "microct", "mri",
    "x-ray", "radiograph", "resolution", "reconstruction",
    "exposure", "brightness", "contrast", "microscop", "histolog",
    "slide", "optical", "imaging", "camera", "oct", "optical coherence tomography", 
    "slit lamp", "ophthalmoscop","b-scan", "echo", "echocard", "ultrasound", 
    "dexA", "xray","m-mode", "waveform image", "scan rate","scanning", "frame", 
    "image pixel size", "lacz", "wholemount", "retinal", "b-scan", "ophthalmoscopy", 
    "slit lamp", "showcase image","waveform image", "xray images"
  ),
  
  blood_hematology = c(
  "blood","hematolog","haematolog","hemoglobin","haemoglobin","hgb",
  "wbc","white blood","lymphocyte","neutrophil","eosinophil",
  "basophil","monocyte","rbc","red blood","platelet","thrombocyte",
  "hematocrit","haematocrit","plasma","serum","coagulation",
  "bleeding","clotting","fibrin","vascular","vein","artery",
  "capillary","hematopoies","haematopoies",
  "bone marrow","cytokine","inflammation marker"
  ),
  
  heart = c(
  "heart","cardiac","cardi","atrium","ventricle","myocard",
  "pericard","endocard","valve","aorta","coronary",
  "pulse","stroke volume","arrhythm","echocard"
  ),
  
  pathology = c(
    "mpath", "patholog", "lesion", "tumou?r", "necrosis",
    "fibrosis", "hyperplasia", "atrophy", "degenerat",
    "inflammat", "edema", "oedema", "hemorrhag", "haemorrhag",
    "malformation", "disease", "defect", "abnormal",
    "histopath", "gross pathology", "process term", "entity term"
  ),
  
  equipment = c(
    "equipment", "instrument", "manufacturer", "protocol",
    "device", "scanner", "microscope", "model number",
    "temperature", "voltage", "current", "settings",
    "parameter", "calibration", "equipment id", "serial number"
  ),
  
  functional_behavioral = c(
    "grip strength", "motor", "behavio", "activity",
    "locomotion", "coordination", "balance", "reflex",
    "hearing", "auditory", "gait", "startle", "olfactory test",
    "response", "sensory", "functional test", "fear conditioning",
    "open field", "rotarod"
  ),
  
  embryo_development = c(
    "embryo", "embryonic", "prenatal", "gestation",
    "developmental stage", "yolk sac", "crown rump",
    "litter", "viability", "alive at dissection",
    "dead at dissection", "time of dissection",
    # generic E-stage pattern
    "e9.5", "e10.5", "e11.5", "e12.5", "e13.5", "e14.5",
    "e15.5", "e16.5", "e17.5", "e18.5"
  )
)


#Categorize
categorize <- function(text) {
  if (is.na(text) || trimws(text) == "") return("other")
  
  matches <- sapply(category_keywords, function(keys) {
    grepl(paste(keys, collapse = "|"), text, ignore.case = TRUE)
  })
  
  if (!any(matches)) return("other")
  
  # First matching category wins (priority = order in list)
  names(matches)[which(matches)[1]]
}

params$group_name <- sapply(params$parameter_name, categorize)
param_groups <- params[, c("group_name", "parameter_name")]
write.csv(param_groups, "../output/parameter_groupings.csv", row.names = FALSE)

