![FitScope](app/www/fitscope-logo-dark.png)

# Table of Contents

- [Introduction](#introduction)
- [Research Objective](#research-objective)
- [Methodology](#methodology)
  - [NIRS Overview](#nirs-overview)
  - [NIRS Study Design](#nirs-study-design)
- [FitScope Tool](#fitscope-tool)
  - [Workflow of FitScope](#the-workflow-of-fitscope)
  - [How to Use the Shiny App](#how-to-use-the-shiny-app)
  - [How to Use the Claude Code Plugin](#how-to-use-the-claude-code-plugin)
  - [Plots and Outputs](#plots-and-output-from-fitscope)
- [Citation](#citation)
- [References](#references)
- [License](#license)

# Introduction

A key indicator of muscle health is skeletal muscle mitochondrial capacity; in other words, how quickly the muscle can use oxygen to regenerate ATP. Reduced oxidative capacity is directly linked to chronic health problems and poorer exercise performance (Maliszewski et al., 2024). Researchers typically measure this key marker from a muscle biopsy, an invasive procedure that requires a 1-2 centimeter incision, a needle, a trained clinician, and a specialized lab (Ross et al., 2023). After researchers take a tissue sample, they must chemically treat muscle fibers and examine them using high-resolution respirometry (e.g., Oroboros) while the tissue is fresh to analyze mitochondrial activity (Ryan et al., 2014). Another method for measuring mitochondrial oxidative capacity is phosphorus magnetic resonance spectroscopy (31P-MRS), a non-invasive option that requires an MRI machine. The need for an MRI scanner makes this method very costly and hard to access. Additionally, movement during measurements is challenging (Maliszewski et al., 2024).

For each participant, a muscle biopsy is burdensome because it requires a local anesthetic, a skin incision, a needle inserted into the muscle, and, in some cases, soreness and pain for about two weeks (Ross et al., 2023). This procedure creates many limitations for biomedical research investigating muscle health. Repeating the procedure on the same participant is difficult, making it hard to track changes over time; in many cases, monitoring changes is essential to determine whether muscle health responds to training or treatment. It is also difficult to run large groups because it requires staff, lab capacity, and funding, which limits the number of participants the study can include. 

Near-infrared spectroscopy (NIRS) lets us measure the same key marker without these limitations. Muscle mitochondrial oxidative capacity can be estimated from outside the body, without anesthesia, incisions, post-procedure soreness, or wet-lab processing, making it more comfortable for patients and practitioners (Ryan et al., 2014). NIRS results show a strong correlation with 31P-MRS (r=0.88-0.95; Ryan et al., 2013). NIRS also correlates with high-resolution respirometry data from biopsy tissue (r=0.61-0.74; Ryan et al., 2014).

Because the procedure is simple and cost-effective, NIRS can be repeated as often as needed, making it especially useful for populations whose muscle health requires ongoing monitoring (e.g., elderly rehab patients or cancer patients with treatment-related cachexia). Skeletal muscle in women with obesity has fewer mitochondria than the muscle of leaner counterparts (Holloway et al., 2007). In addition, aging individuals and patients with type 2 diabetes have lower mitochondrial capacity (Toledo & Goodpaster, 2013). In these populations, physical activity can improve mitochondrial capacity, and tracking helps inform and improve treatment programs (Toledo & Goodpaster, 2013). Because it can be repeated as often as needed on any patient, with no recovery time and no incision, this monitoring can occur outside the laboratory. In addition, it allows for clinical use for those who are medically compromised, whether they suffer from a chronic disease or are in recovery from an injury. Every biopsy can pose a risk of infection and bleeding at the site (Ross et al., 2023), making any biopsy on compromised patients a health risk, and the risk increases with repeated biopsies. Across the biopsy techniques reviewed, hematomas and bruising occurred in up to one-third of patients, and wound infections occurred in about 1-5% of open biopsies (Ross et al., 2023).

A study that follows participants in a 12-week training program needs six measurements per participant. With biopsies, that is six incisions in the same muscle. With NIRS, it would be six short sessions of about 15 minutes each without ever breaking the skin. 

Making mitochondrial oxidative capacity more accessible and easier to measure does not make it automatically easier to analyze. Although NIRS reduces many physical barriers and limitations of muscle biopsies, the raw data is challenging to interpret. When NIRS is used, it captures signals from optical channels at high sampling frequencies, resulting in thousands of values in the raw data. Oxidative capacity is calculated from slope changes, which requires data cleaning, blood-volume change corrections, and analysis to identify oxygen consumption rates in each arterial occlusion. After cleaning the data, we fit the measurements to an exponential model to estimate the mitochondrial recovery time constant and rate constant.  

Primarily, the data results are not always physiologically reliable. Signal noise, movement artifacts, incorrect occlusion identification, and poorly fitted recovery curves can cause mitochondrial capacity to be estimated incorrectly. In prior research studies, the authors used MATLAB (the MathWorks, Inc. MA, USA), which is a programming language that requires a significant amount of prior knowledge to be able to use it (Ryan et al., 2014; Tandirerung et al, 2024). In a single session, the NIRS device used in this study records measurements every 0.1 seconds across six optical channels, producing thousands of data points. Processing this data and evaluating its reliability requires multiple challenging analytical steps. 

To address these challenges, we developed FitScope, an open-source tool that cleans, analyzes, and visualizes raw NIRS data to estimate skeletal muscle mitochondrial oxidative capacity. FitScope automates the analytical process, from cleaning the data and performing blood-volume corrections to estimating oxygen consumption rates, evaluating result reliability, and fitting recovery curves. We built two interfaces to improve accessibility: an interactive R Shiny application and a Claude Code plugin. Researchers can upload raw data captured in the R Shiny app and visualize results without writing code. The Claude Code plugin lets users analyze their NIRS data by describing their desired tasks in simple, everyday language.  

## Research objective

The overall aim of this study is to determine whether NIRS can provide a valid, trustworthy, non-invasive estimate of skeletal muscle mitochondrial oxidative capacity in women with overweight or obesity. To achieve that aim, we developed FitScope, an open-source tool that produces these estimates from raw NIRS data in a standardized way.

1. Assess signal quality and feasibility.
Determine whether usable NIRS signals can be obtained from the lateral (Rx1) and medial (Rx2) gastrocnemius of women aged 18–60 with a BMI of 25–40 kg/m². We will quantify this as the proportion of participants and probes that meet predefined quality-control criteria: Fit Factor, TSI%, resting-occlusion correlation, fit convergence, and R² threshold.

2. Estimate mitochondrial oxidative capacity.
Quantify the recovery time constant (Tc) and rate constant (k) for each participant by fitting a mono-exponential model to post-exercise mVO₂ recovery. Compare these values between the lateral and medial probe sites and with published values from lean, healthy populations.

3. Develop a standardized analysis pipeline.
Build FitScope to carry out the lab's pre-specified processing steps on raw Oxysoft exports. These steps include data cleaning, blood-volume correction, occlusion identification, mVO₂ calculation per occlusion, and recovery-curve fitting. FitScope will offer two front ends, an R Shiny app and a Claude Code plugin, and both will run the same underlying scripts so that they produce identical outputs.


# Methodology 
## NIRS Overview

NIRS is a noninvasive way to measure mitochondrial function through hemoglobin/myoglobin oxygenation, without cutting into the body or taking a sample. A sensor sits on the skin and sends near-infrared light into the underlying tissue, where it scatters back to a detector on the sensor. Oxygenated (O2Hb) and deoxygenated (HHb) hemoglobin absorb near-infrared light differently, allowing the NIRS system to measure returning light and record changes in muscle oxygenation (Cheatham Lab, 2014). NIRS also provides the sum of these two signals as total hemoglobin (tHb), reflecting blood volume under the sensors. Because NIRS captures both oxygen delivery and consumption simultaneously, a blood pressure cuff (pumped above systolic blood pressure) stops arterial blood flow, allowing only oxygen consumption to be recorded at that moment (Ryan et al., 2012; Ryan et al., 2014). O2Hb falls, and HHb rises during this event, and the slope of this change is the muscle's oxygen consumption (mVO2). Plotting these slopes post-exercise lets us assess mitochondrial capacity (Ryan et al., 2014), which we explain further in the following section.

---
<p align="center">
  <img
    src="https://raw.githubusercontent.com/fitgutlab/FitScope/main/www/HB%20Model%20FitScope.jpg"
    width="100%"
    alt="Hemoglobin oxygen delivery to muscle tissue and ATP production"
  />
</p>


## NIRS Study Design  

Our study's (IRB: NCR267336) participant demographics are women aged 18-60 with a BMI of 25-40 kg/m2. Previous studies (Ryan et al., 2012; Ryan et al., 2014) have tested the viability of using NIRS as a substitute for muscle biopsies; however, we do not yet know whether NIRS is able to reliably capture mitochondrial efficiency in women with overweight or obesity, i.e., with distinct body fat compositions. The literature is heterogeneous, and adipose tissue may interfere with NIRS. 

NIRS is a straightforward procedure. We begin by having the participant lie down with legs extended and relaxed. We place the NIRS probes Rx1 and Rx2 on the thickest parts of the lateral (Rx1) and medial (Rx2) sides of the calf, and because they are highly light-sensitive, we wrap both probes in dark athletic tape. Placing the probes here yields a more reliable signal because more muscle is under the sensor and placement is more consistent (Ryan et al., 2012). We place a blood pressure cuff on the thigh of the same leg to briefly cut blood and oxygen flow to the sensors during the procedure.

We start off the test with a two-minute resting measurement. We then inflate the cuff to around 240 mm Hg for 30 seconds to cut oxygen supply to the muscle, while NIRS continues to measure O2Hb and HHb signals. The slope of the HHb signal during this occlusion helps estimate the baseline resting muscle oxygen consumption (mVO2) (Ryan et al., 2014). 

After hemoglobin values return to baseline during reperfusion, the participant performs steady plantar flexions to a metronome pace of 60 bpm for 30 seconds. We again let all values return to baseline, then perform transient occlusions every 8 seconds via cuff inflation for 3 minutes. 

Each occlusion shows a slope representing mVO2; plotted together, they give a picture of oxygen consumption through a decay curve. Fitting this curve with the equation:

**mV̇O₂(t) = Rest + Delta · e^(−t/Tc)**

This yields **Tc**, the recovery time constant: a number that tells us how quickly mVO2 falls back to resting levels post-exercise. Tc is tied to the **rate constant k=1/Tc**, meaning that **lower Tc/higher k values correspond to faster muscle recovery** (Ryan et al., 2014). Biologically, faster muscle recovery reflects greater mitochondrial respiratory capacity and higher metabolic flexibility (i.e., the body's adaptive capacity to shift fuel selection between carbohydrates (glucose) and fats (fatty acids) depending on immediate energy demands and food availability).

---
<table>
  <tr>
    <td align="center">
      <img src="https://raw.githubusercontent.com/fitgutlab/FitScope/main/www/Cuff.jpg" height="300" alt="Occlusion cuff on thigh"/>
    </td>
    <td align="center">
      <img src="https://raw.githubusercontent.com/fitgutlab/FitScope/main/www/Laser.jpg" height="300" alt="Laser probe setup on forearm" />
    </td>
  </tr>
</table>


## FitScope Tool  
FitScope is an integrated tool of an R Shiny app and a Claude Code plugin for estimating **skeletal muscle
mitochondrial oxidative capacity** from near-infrared spectroscopy (NIRS)
arterial-occlusion recordings, following the repeated-occlusion method described in previous literature (Ryan et al. 2012 ; yan et al. 2014).

The tool requires uploading a raw Oxysoft NIRS export file. The raw file will be cleaned, analyzed, and visualized. The scripts below perform the cleaning, analysis, and plotting steps.  

```
cleaning_STEP/clean_nirs.R     raw .xlsx export -> cleaned, one-row-per-second dataset
analysis_STEP/analyse_nirs.R   blood-volume correction, mVO2 per occlusion, the Tc fit
plotting_STEP/plot_nirs.R      the six standard figures from the source papers
```

### The workflow of FitScope

FitScope has two options: the R Shiny App and the Claude Code plugin; the procedures for both are explained below:   
| | |
|---|---|
| **`app/`** | A Shiny app: upload a raw export, run clean → analyze → plot, view QC, the recovery-fit table with plausibility flags, and the figures. |
| **`.claude-plugin/`, `skills/`, `agents/`** | A Claude Code plugin: a `nirs-pipeline` skill that runs the pipeline conversationally, and a `pipeline-runner` subagent for batch runs. |

### How to use the Shiny app 
#### 1. Clone the repo & install R dependencies & launch the Shiny app
If R studio/Positron is already installed, it can run app.R; it can also run in the Terminal. If running on the Terminal, it requires the repo to be cloned and R and specific R packages to be installed.   
 
```bash
git clone https://github.com/fitgutlab/FitScope.git
cd FitScope

#Install R dependencies - the pipeline scripts' packages plus the app's own
  R -e 'install.packages(c("shiny","DT","base64enc","readxl","dplyr","tidyr","readr","ggplot2","patchwork"))'

#Launch the Shiny app
  cd app
  R -e 'shiny::runApp(".", launch.browser = TRUE)'
```

### How to use the Claude Code Plugin

#### 1. Download Claude Code  
Claude Code needs to be installed in the Terminal or in an IDE (eg., Visual Studio Code, Positron).

| | |
|---|---|
| **Claude Code** | The CLI, desktop app, or VS Code/JetBrains extension. See [code.claude.com/docs](https://code.claude.com/docs). |

#### 2. Open a Claude Code session
It is important to locate the working directory  
```bash
cd ~/path/to/your/study        # wherever your raw .xlsx exports live
claude
```

#### 3. Install the plugin

At Claude Code's `>` prompt:

```
/plugin marketplace add fitgutlab/FitScope
/plugin install fitscope@fitgutlab
```

Restart Claude Code (`/exit`, then `claude` again) — plugins load at startup.

#### 4. Run the FitScope pipeline 

```
/fitscope:nirs-pipeline Practice12.xlsx  #This is a sample of how you can ask Claude to read a raw file 
```

or just describe the task in plain english language — the skill triggers on its own:

```
clean and analyse Practice12.xlsx, is the Tc trustworthy? #This is a sample prompt 
```

#### The Output: 
The tool produces outputs from the cleaining, analysis and ploting steps: 

| output | contents |
|---|---|
| `<id>_cleaned_1s.csv` | one row per second: O2Hb, HHb, tHb, phase, occlusion label |
| `<id>_qc_report.csv` | per-probe Fit Factor, TSI%, resting-occlusion correlation |
| `<id>_mvo2.csv` | mVO2 per occlusion × signal × correction |
| `<id>_recovery_fit.csv` | Rest, Delta, End, **Tc**, **k**, R², `converged` |
| `<id>_fig1..fig5.png`, `<id>_fig6_mvo2_recovery_fit.png` | six figures |

#### Plots and Output from Fitscope 
---

<table>
  <tr>
    <td align="center" width="50%">
      <img src="https://raw.githubusercontent.com/fitgutlab/FitScope/main/www/practice_4_plots.png" width="100%" alt="Practice 4 plots" />
    </td>
    <td align="center" width="50%">
      <img src="https://raw.githubusercontent.com/fitgutlab/FitScope/main/www/practice_4_fig2_recovery_series.png" width="100%" alt="Recovery series" />
    </td>
  </tr>
  <tr>
    <td align="center" width="50%">
      <img src="https://raw.githubusercontent.com/fitgutlab/FitScope/main/www/practice_4_fig3_cuff_magnification.png" width="100%" alt="Cuff magnification" />
    </td>
    <td align="center" width="50%">
      <img src="https://raw.githubusercontent.com/fitgutlab/FitScope/main/www/practice_4_fig4_resting_occlusion.png" width="100%" alt="Resting occlusion" />
    </td>
  </tr>
  <tr>
    <td align="center" width="50%">
      <img src="https://raw.githubusercontent.com/fitgutlab/FitScope/main/www/practice_4_fig5_probe_comparison.png" width="100%" alt="Probe comparison" />
    </td>
    <td align="center" width="50%">
      <img src="https://raw.githubusercontent.com/fitgutlab/FitScope/main/www/practice_4_fig6_mvo2_recovery_fit.png" width="100%" alt="MVO2 recovery fit" />
    </td>
  </tr>
  <tr>
    <td align="center" width="50%">
      <img src="https://raw.githubusercontent.com/fitgutlab/FitScope/main/www/practice_4_fig1_protocol_overview.png" width="100%" alt="Protocol overview" />
    </td>
    <td align="center" width="50%">
      <img src="https://raw.githubusercontent.com/fitgutlab/FitScope/main/www/mOv.png" width="100%" alt="MVO2 plot" />
    </td>
  </tr>
</table>


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

Tandirerung, F. J., Jamieson, A., Hendrick, E., Hughes, A. D., & Jones, S. (2024). Near-infrared spectroscopy (NIRS) in vivo assessment of skeletal muscle oxidative capacity: a comparison of results from short versus long exercise protocols and reproducibility in non-athletic adults. Frontiers in Physiology, 15. https://doi.org/10.3389/fphys.2024.1429673

Toledo, F. G. S., & Goodpaster, B. H. (2013). The role of weight loss
and exercise in correcting skeletal muscle mitochondrial abnormalities
in obesity, diabetes and aging. *Molecular and Cellular Endocrinology,
379*(1–2), 30–34.

## License

MIT — see [`LICENSE`](LICENSE).
