![FitScope](app/www/fitscope-logo-dark.png)

# Introduction

A key indicator when evaluating muscle health status is by examining skeletal muscle mitochondrial capacity, in other words, how fast the muscle is able to use oxygen to regenerate ATP. Reduced oxidative capacity is shown to have direct links to chronic health problems, as well as poorer exercise performance (Maliszewski et al., 2024). This key marker is typically measured from a muscle biopsy, an invasive procedure that requires a 1-2 centimeter incision, a needle, a trained clinician, and a specialized lab (Ross et al., 2023). Once a tissue sample is incised from the patient, the muscle fibers must now be chemically treated and examined using a high-resolution respirometry while the tissue is fresh, in order to analyze the mitochondrial activity (Ryan et al., 2014).

For each participant this is shown to be burdensome as it requires a local anesthetic, an incision in the skin, a needle inserted into their muscle, and in some cases, soreness and pain remaining for about two weeks (Ross et al., 2023). The nature of this procedure causes many limitations. It is difficult to repeat this on the same participant, which makes tracking changes over time challenging, and in many cases, it is imperative to monitor changes to examine if muscle health is responding to training or treatment. It also proves to be difficult to run on large groups due to need for staff, lab capacity, and cost, limiting the amount of participants that the study can include. 

Near-infrared spectroscopy (NIRS) allows us to examine the same same exact key marker, without these limitations. The same indicator can be estimated from outside the body, with no anesthesia, no incision, no post-procedure soreness, and no wet lab processing, making it more comfortable for the patient and the practitioner (Ryan et al., 2014). The other option that is non-invasive, phosphorus magnetic resonance spectroscopy (31P-MRS), requires the usage of an MRI machine, resulting in a costly procedure and making it hard to access (Maliszewski et al., 2024). NIRS results show a strong correlation with 31P-MRS (r=0.88-0.95; Ryan et al., 2013). NIRS also correlates with measurement data from high-resolution respirometry on biopsy tissue (r=0.61-0.74; Ryan et al., 2014).

Due to the simplicity of the procedure, NIRS can be repeated as often as needed, making it extremely useful for populations who have muscle health that needs constant monitoring. The skeletal muscle in women with obesity is shown to have fewer mitochondria, when compared to the muscle of leaner counterparts (Holloway et al., 2007). In addition, aging individuals and patients with type 2 diabetes have lower mitochondrial capacity (Toledo & Goodpaster, 2013). In these populations, the mitochondrial capacity can improve with physical activity, and tracking is how treatment programs can be formulated and improved (Toledo & Goodpaster, 2013). A method that can be repeated as often as needed on any patient, with no recovery time and no incision, makes this monitoring possible outside of the laboratory. In addition, it allows for clinical usage for those who are medically compromised, whether they suffer from a chronic disease or are in recovery from an injury. Every biopsy can pose as a risk of infection and bleeding at the site (Ross et al., 2023), making any biopsy on compromised patients a health risk, and the risk increasing per repeated biopsy. Upon the biopsy techniques reviewed, hematomas and bruising was reported in up to one third of the patients and wound infections were seen in about 1-5% of open biopsies (Ross et al., 2023).

A study that follows participants in a 12-week training program needs six measurements per participant. With biopsies, that is six incisions in the same muscle. With NIRS, it would be six short sessions of about 15 minutes each without ever breaking the skin. 

Intro about FitScope: The raw data given by the NIRS is quite challenging to interpret. Technically the actual values shown in the raw data do not mean anything, instead oxidative capacity is calculated using changes in slope, meaning high levels of data cleaning and analysis is required. In prior research studies, its authors used MATLAB, which is a programming language that requires a significant amount of prior knowledge to be able to use it. The need to use MATLAB stems from the fact that raw data comes with thousands of data points, majority of which are not as relevant (Tandirerung et al, 2024). The NIRS machine records data every .1 seconds and there are 6 lens that record data hence thousands and thousands of data points are recorded. To solve this issue of data interpretation we have developed FitScope. A tool that will clean, analyze, and visualize raw NIRS data. In addition to building an app we also developed a Claude Code plugin. This is especially significant because it does not require users to even download R studio or Visual Studio Code. Users just need to download their raw data and upload it to their Claude account.   

## Research objective
Take a raw Oxysoft NIRS export from a repeated-occlusion recovery-kinetics
protocol and produce a **trustworthy** Tc (and k) for each subject — the
operative word being *trustworthy*, because, per above, a converged fit is
not automatically one. The pipeline this repository ships was specified
decision-by-decision by the lab's data owner (recorded in
`data_cleaning_transcript.md` and `NIRS_Pipeline_Questions_and_Challenges.docx`),
not derived or guessed at, and the two front ends below exist to run that
exact pipeline without ever reimplementing it.

# NIRS Overview

Near-infrared spectroscopy (NIRS) is a noninvasive way of measuring mitochondrial functioning through hemoglobin/myoglobin oxygenation, without cutting into the body or taking a sample. A sensor sits on the skin and sends near-infrared light to the tissue underneath where it scatters back to a detector on the sensor. Oxygenated (O2Hb) and deoxygenated (HHb) hemoglobin absorb near-infrared light at different levels, allowing the NIRS system to measure how much light is returning to the detectors and record changes in muscle oxygenation (Cheatham Lab, 2014). NIRS also provides the sum of these two signals as total hemoglobin (tHb), reflecting blood volume under the sensors. Because NIRS reflects oxygen delivered and consumed at once, a blood pressure cuff (pumped to above systolic blood pressure) stops arterial blood flow, allowing only oxygen consumption to be recorded at that moment (Ryan et al., 2012; Ryan et al., 2014). O2Hb falls and HHb rises during this event, and the slope of this change is the muscle's oxygen consumption (mVO2). Plotting these slopes post-exercise allows us to assess mitochondrial capacity (Ryan et al., 2014), which will be explained more thoroughly in the following section.

# NIRS Procedure 

Near-infrared spectroscopy (NIRS) is a straightforward procedure. Our participant demographics are women of ages 18-60 with a BMI >25. Previous studies (Ryan et al., 2012; Ryan et al., 2014) have tested the viability of using NIRS as a substitute for muscle biopsies, however we do not yet know whether NIRS is able to reliably capture mitochondrial efficiency in women with overweight or obesity.

We initiate by having the participant lie down, legs extended and relaxed. The NIRS probes Rx1 and Rx2 are placed on the thickest parts of the lateral (Rx1) and medial (Rx2) sides of the calf, and due to their high light sensitivity we wrap both probes in dark athletic tape. Placing the probes here allows us to obtain a more reliable signal due to the higher presence of muscle under the sensor, and allowing for consistent placement (Ryan et al., 2012). A blood pressure cuff is placed on the thigh of the same leg to cut blood and oxygen flow to the sensors for a brief period during the procedure.

We start off the test with a two minute resting measurement. The cuff is then inflated to around 240 mm HG for 30 seconds to cut oxygen supply to the muscle, while NIRS continues to measure O2Hb and HHb signals. The slope of the HHb signal during this occlusion helps measure the resting muscle oxygen consumption (mVO2) baseline value (Ryan et al., 2014). 

After letting hemoglobin values return to baseline we have the participant perform steady plantar flexions to a metronome pace of 60bpm for 30 seconds. Transient occlusions are then performed every 8 seconds via cuff inflation over a duration of 3 minutes. 

Each occlusion shows a slope representing mVO2, which gives us a picture of oxygen consumption through a curve of decay when they are plotted together. Fitting this curve with the equation:

**mV̇O₂(t) = Rest + Delta · e^(−t/Tc)**

yields **Tc**, which is the time constant of recovery: a number telling us the speed at which mVO2 falls back to resting levels post-exercise. Tc is tied to the **rate constant k=1/Tc**, meaning that **lower Tc/higher k values correspond to faster muscle recovery** (Ryan et al., 2014). Biologically, faster muscle recovery reflects greater mitochondrial respiratory capacity.

Questions for Carmen: 
Is my incorporation of the two articles good or should I reference them more specifically?

# Methodology 
# FitScope 
FitScope is a R Shiny app and a Claude Code plugin for estimating **skeletal muscle
mitochondrial oxidative capacity** from near-infrared spectroscopy (NIRS)
arterial-occlusion recordings, following the repeated-occlusion method seen in previous literature (Ryan et al. 2012 ; yan et al. 2014).

The tool requires a raw Oxysoft NIRS export file to be uploaded. The raw file will be cleaned, analyzed and visualized. The scripts below are the scripts required to undergo the cleaning, analysis, and plotting steps.  

```
cleaning_STEP/clean_nirs.R     raw .xlsx export -> cleaned, one-row-per-second dataset
analysis_STEP/analyse_nirs.R   blood-volume correction, mVO2 per occlusion, the Tc fit
plotting_STEP/plot_nirs.R      the six standard figures from the source papers
```

## The workflow of FitScope

FitScope has two options the R Shiny App and the Claude Code plugin, the procedures of both are explained below:   
| | |
|---|---|
| **`app/`** | A Shiny app: upload a raw export, run clean → analyse → plot, view QC, the recovery-fit table with plausibility flags, and the figures. |
| **`.claude-plugin/`, `skills/`, `agents/`** | A Claude Code plugin: a `nirs-pipeline` skill that runs the pipeline conversationally, and a `pipeline-runner` subagent for batch runs. |

## How to use the Shiny app 
### 1. Clone the repo & Install R dependencies & Launch the Shiny app
If  R studio/Positron is already installed, it can run the app.R , it can also run in the Terminal. If running on the Terminal, it requires the repo to be cloned and R and specific R packages to be installed.   
 
```bash
git clone https://github.com/fitgutlab/FitScope.git
cd FitScope

#Install R dependencies - the pipeline scripts' packages plus the app's own
  R -e 'install.packages(c("shiny","DT","base64enc","readxl","dplyr","tidyr","readr","ggplot2","patchwork"))'

#Launch the Shiny app
  cd app
  R -e 'shiny::runApp(".", launch.browser = TRUE)'
```

## How to use the Claude Code Plugin

### 1. Download Claude Code  
The Claude Code needs be installed in the Terminal or in a IDE (eg. Visual Studio Code, Positron).

| | |
|---|---|
| **Claude Code** | The CLI, desktop app, or VS Code/JetBrains extension. See [code.claude.com/docs](https://code.claude.com/docs). |

### 2. Open a Claude Code session
It is important to locate the working directory  
```bash
cd ~/path/to/your/study        # wherever your raw .xlsx exports live
claude
```

### 3. Install the plugin

At Claude Code's `>` prompt:

```
/plugin marketplace add fitgutlab/FitScope
/plugin install fitscope@fitgutlab
```

Restart Claude Code (`/exit`, then `claude` again) — plugins load at startup.

### 4. Run the FitScope pipeline 

```
/fitscope:nirs-pipeline Practice12.xlsx  #This is a sample of how you can ask Claude to read a raw file 
```

or just describe the task in plain english language — the skill triggers on its own:

```
clean and analyse Practice12.xlsx, is the Tc trustworthy? #This is a sample prompt 
```

## Sample Figures (Philip) 

| output | contents |
|---|---|
| `<id>_cleaned_1s.csv` | one row per second: O2Hb, HHb, tHb, phase, occlusion label |
| `<id>_qc_report.csv` | per-probe Fit Factor, TSI%, resting-occlusion correlation |
| `<id>_mvo2.csv` | mVO2 per occlusion × signal × correction |
| `<id>_recovery_fit.csv` | Rest, Delta, End, **Tc**, **k**, R², `converged` |
| `<id>_fig1..fig5.png`, `<id>_fig6_mvo2_recovery_fit.png` | the six figures |

---
<div align="center">
  <img src="https://github.com/fitgutlab/FitScope/main/www/practice_4_plots.png" />
  <img src="https://github.com/fitgutlab/FitScope/main/www/practice_4_fig2_recovery_series.png" width="45%" />
  <img src="https://github.com/fitgutlab/FitScope/main/www/practice_4_fig3_cuff_magnification.png" width="45%" />
  <img src="https://github.com/fitgutlab/FitScope/main/www/practice_4_fig4_resting_occlusion.png" width="45%" />
  <img src="https://github.com/fitgutlab/FitScope/main/www/practice_4_fig5_probe_comparison.png" width="45%" />
  <img src="https://github.com/fitgutlab/FitScope/edit/main/www/practice_4_fig6_mvo2_recovery_fit.png" width="45%" />
  <img src="https://github.com/fitgutlab/FitScope/main/www/practice_4_fig1_protocol_overview.png" width="45%" />
  <img src="https://github.com/fitgutlab/FitScope/main/www/mOv.png" width="45%" />
</div>


---

## Citation

Appiah, P., de Torres, C., Machaz, I., Osorio, A. & Ortega-Santos, C. (2026).
fitgutlab/FitScope: v1.0.0 (Version 1) [Computer software]. Zenodo.
https://doi.org/10.5281/zenodo.22885722

## References 

Cheatham Lab. (2014). Near-infrared spectroscopy. https://cheathamlab.com/index.php/near-infrared-spectroscopy/

Holloway, G. P., Thrush, A. B., Heigenhauser, G. J. F., Tandon, N. N.,
Dyck, D. J., Bonen, A., & Spriet, L. L. (2007). Skeletal muscle
mitochondrial FAT/CD36 content and palmitate oxidation are not decreased
in obese women. *American Journal of Physiology-Endocrinology and
Metabolism, 292*(6), E1782–E1789.

Maliszewski, K., Feldmann, A., McCully, K. K., & Julian, R. (2024). A
systematic review of the relationship between muscle oxygen dynamics
and energy rich phosphates. Can NIRS help? *BMC Sports Science, Medicine
and Rehabilitation, 16*, Article 25.
https://doi.org/10.1186/s13102-024-00809-5

Ross, L., McKelvie, P., Reardon, K., & Day, B. J. (2023). Muscle biopsy
practices in the evaluation of neuromuscular disease: A systematic
literature review. *Neuropathology and Applied Neurobiology, 49*(1),
Article e12888. https://doi.org/10.1111/nan.12888

Ryan, T. E., Brophy, P., Lin, C.-T., Hickner, R. C., & Neufer, P. D.
(2014). Assessment of in vivo skeletal muscle mitochondrial respiratory
capacity in humans by near-infrared spectroscopy: A comparison with in
situ measurements. *The Journal of Physiology, 592*(15), 3231–3241.
https://doi.org/10.1113/jphysiol.2014.274456

Ryan, T. E., Southern, W. M., Reynolds, M. A., & McCully, K. K. (2013).
A cross-validation of near-infrared spectroscopy measurements of
skeletal muscle oxidative capacity with phosphorus magnetic resonance
spectroscopy. *Journal of Applied Physiology, 115*(12), 1757–1766.
https://doi.org/10.1152/japplphysiol.00835.2013

Toledo, F. G. S., & Goodpaster, B. H. (2013). The role of weight loss
and exercise in correcting skeletal muscle mitochondrial abnormalities
in obesity, diabetes and aging. *Molecular and Cellular Endocrinology,
379*(1–2), 30–34.

## License

MIT — see [`LICENSE`](LICENSE).
