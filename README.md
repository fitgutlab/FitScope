![FitScope](app/www/fitscope-logo-dark.png)

# Introduction

A key indicator of muscle health is skeletal muscle mitochondrial capacity; in other words, how quickly the muscle can use oxygen to regenerate ATP. Reduced oxidative capacity is directly linked to chronic health problems and poorer exercise performance (Maliszewski et al., 2024). Researchers typically measure this key marker from a muscle biopsy, an invasive procedure that requires a 1-2 centimeter incision, a needle, a trained clinician, and a specialized lab (Ross et al., 2023). Once a tissue sample is taken, researchers must chemically treat muscle fibers and examine them using high-resolution respirometry (e.g., Oroboros) while the tissue is fresh to analyze mitochondrial activity (Ryan et al., 2014).

For each participant, this is burdensome because it requires a local anesthetic, a skin incision, a needle inserted into the muscle, and, in some cases, soreness and pain for about two weeks (Ross et al., 2023). This procedure creates many limitations for biomedical research investigating muscle health. It is difficult to repeat the procedure on the same participant, making it hard to track changes over time; in many cases, monitoring changes is imperative to determine whether muscle health responds to training or treatment. It is also difficult to run on large groups because it requires staff, lab capacity, and funding, limiting the number of participants the study can include. 

Near-infrared spectroscopy (NIRS) lets us measure the same key marker without these limitations. Muscle mitochondrial oxidative capacity can be estimated from outside the body, without anesthesia, incisions, post-procedure soreness, or wet-lab processing, making it more comfortable for patients and practitioners (Ryan et al., 2014). The other non-invasive option, phosphorus magnetic resonance spectroscopy (31P-MRS), requires an MRI machine, making it costly and hard to access (Maliszewski et al., 2024). NIRS results show a strong correlation with 31P-MRS (r=0.88-0.95; Ryan et al., 2013). NIRS also correlates with high-resolution respirometry data from biopsy tissue (r=0.61-0.74; Ryan et al., 2014).

Because the procedure is simple and cost-effective, NIRS can be repeated as often as needed, making it extremely useful for populations whose muscle health needs constant monitoring. Skeletal muscle in women with obesity has fewer mitochondria than the muscle of leaner counterparts (Holloway et al., 2007). In addition, aging individuals and patients with type 2 diabetes have lower mitochondrial capacity (Toledo & Goodpaster, 2013). In these populations, mitochondrial capacity can improve with physical activity, and tracking helps inform and improve treatment programs (Toledo & Goodpaster, 2013). A method that can be repeated as often as needed on any patient, with no recovery time and no incision, makes this monitoring possible outside of the laboratory. In addition, it allows for clinical use for those who are medically compromised, whether they suffer from a chronic disease or are in recovery from an injury. Every biopsy can pose a risk of infection and bleeding at the site (Ross et al., 2023), making any biopsy on compromised patients a health risk, and the risk increases with repeated biopsies. Across the biopsy techniques reviewed, hematomas and bruising were reported in up to one third of patients, and wound infections were seen in about 1-5% of open biopsies (Ross et al., 2023).

A study that follows participants in a 12-week training program needs six measurements per participant. With biopsies, that is six incisions in the same muscle. With NIRS, it would be six short sessions of about 15 minutes each without ever breaking the skin. 

Making mitochondrial oxidative capacity more accessible and easier to measure, does not make it automatically easier to analyze. Even though NIRS reduces a lot of the physical barriers and limitations that come with muscle biopsies, the raw NIRS data is challenging to interpret. When NIRS is used, it captures signals from optical channels at high sampling frequencies, which results in thousands of values shown in the raw data. Oxidative capacity is calculated using changes in slope, which requires of data cleaning, blood-volume change corrections, and analysis to identify oxygen consumption rates in each arterial occlusion. After the data is cleaned, the measurements are then placed into an exponential model that estimates the mitochondrial recovery time constant and rate constant.  

Primarily, the data reuslts is not always physiologically reliable. There can be signal noise, movement artifcats, incorrrect occulusion identification, and poorly fitted recovery curves that can cause mitochondiral capacity to be incorrectly estimated. In prior research studies, the authors used MATLAB (the MathWorks, Inc. MA, USA), which is a programming language that requires a significant amount of prior knowledge to be able to use it (Ryan et al., 2014; Tandirerung et al, 2024). The need to use MATLAB stems from the fact that raw data comes with thousands of data points, majority of which are not as relevant (Tandirerung et al, 2024). The NIRS machine records data every 0.1 seconds, and 6 lenses record data, so thousands of data points are recorded. 

To address this issue of data interpretation, we have developed FitScope. A tool that will clean, analyze, and visualize raw NIRS data to estimate skeletal muscle mitochondrial oxidative capacity. In addition to building an app, we also developed a Claude Code plugin. This is especially significant because it does not require users to even download RStudio or Visual Studio Code. Users just need to download their raw data and upload it to their Claude account.   

## Research objective
Take a raw NIRS export from a repeated-occlusion recovery-kinetics
protocol and produce a **trustworthy** Tc (and k) for each subject — the
operative word being *trustworthy*, because, per above, a converged fit is
not automatically one. The pipeline this repository ships was specified
decision-by-decision by the lab's data owner (recorded in
`data_cleaning_transcript.md` and `NIRS_Pipeline_Questions_and_Challenges.docx`),
not derived or guessed at, and the two front ends below exist to run that
exact pipeline without ever reimplementing it.

# Methodology 
## NIRS Overview

NIRS is a noninvasive way to measure mitochondrial function through hemoglobin/myoglobin oxygenation, without cutting into the body or taking a sample. A sensor sits on the skin and sends near-infrared light to the tissue underneath, where it scatters back to a detector on the sensor. Oxygenated (O2Hb) and deoxygenated (HHb) hemoglobin absorb near-infrared light differently, allowing the NIRS system to measure returning light and record changes in muscle oxygenation (Cheatham Lab, 2014). NIRS also provides the sum of these two signals as total hemoglobin (tHb), reflecting blood volume under the sensors. Because NIRS reflects oxygen delivery and consumption simultaneously, a blood pressure cuff (pumped above systolic blood pressure) stops arterial blood flow, allowing only oxygen consumption to be recorded at that moment (Ryan et al., 2012; Ryan et al., 2014). O2Hb falls, and HHb rises during this event, and the slope of this change is the muscle's oxygen consumption (mVO2). Plotting these slopes post-exercise lets us assess mitochondrial capacity (Ryan et al., 2014), which we explain in the following section.

HB Model

## NIRS Study Design  

NIRS is a straightforward procedure. Our participant demographics are women aged 18-60 with a BMI of 25-40 kg/m2. Previous studies (Ryan et al., 2012; Ryan et al., 2014) have tested the viability of using NIRS as a substitute for muscle biopsies; however, we do not yet know whether NIRS is able to reliably capture mitochondrial efficiency in women with overweight or obesity, i.e., with distinct body fat compositions. The literature is heterogeneous, considering how adipose tissue might interfere with NIRS. 

We begin by having the participant lie down with legs extended and relaxed. We place the NIRS probes Rx1 and Rx2 on the thickest parts of the lateral (Rx1) and medial (Rx2) sides of the calf, and because they are highly light-sensitive, we wrap both probes in dark athletic tape. Placing the probes here gives a more reliable signal because more muscle is under the sensor and allows consistent placement (Ryan et al., 2012). A blood pressure cuff is placed on the thigh of the same leg to briefly cut blood and oxygen flow to the sensors during the procedure.

We start off the test with a two-minute resting measurement. We then inflate the cuff to around 240 mm Hg for 30 seconds to cut oxygen supply to the muscle, while NIRS continues to measure O2Hb and HHb signals. The slope of the HHb signal during this occlusion helps estimate the baseline resting muscle oxygen consumption (mVO2) (Ryan et al., 2014). 

After hemoglobin values return to baseline, the participant performs steady plantar flexions to a metronome pace of 60 bpm for 30 seconds. We then perform transient occlusions every 8 seconds via cuff inflation for 3 minutes. 

Each occlusion shows a slope representing mVO2, which, when plotted together, gives a picture of oxygen consumption through a decay curve. Fitting this curve with the equation:

**mV̇O₂(t) = Rest + Delta · e^(−t/Tc)**

yields **Tc**, which is the time constant of recovery: a number telling us the speed at which mVO2 falls back to resting levels post-exercise. Tc is tied to the **rate constant k=1/Tc**, meaning that **lower Tc/higher k values correspond to faster muscle recovery** (Ryan et al., 2014). Biologically, faster muscle recovery reflects greater mitochondrial respiratory capacity.

PICTURE OF THE TEST 

## FitScope Tool  
FitScope is an integrated tool of an R Shiny app and a Claude Code plugin for estimating **skeletal muscle
mitochondrial oxidative capacity** from near-infrared spectroscopy (NIRS)
arterial-occlusion recordings, following the repeated-occlusion method described in previous literature (Ryan et al. 2012 ; yan et al. 2014).

The tool requires a raw Oxysoft NIRS export file to be uploaded. The raw file will be cleaned, analyzed and visualized. The scripts below are the scripts required to undergo the cleaning, analysis, and plotting steps.  

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
#### 1. Clone the repo & Install R dependencies & Launch the Shiny app
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

### How to use the Claude Code Plugin

#### 1. Download Claude Code  
The Claude Code needs be installed in the Terminal or in a IDE (eg. Visual Studio Code, Positron).

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

Toledo, F. G. S., & Goodpaster, B. H. (2013). The role of weight loss
and exercise in correcting skeletal muscle mitochondrial abnormalities
in obesity, diabetes and aging. *Molecular and Cellular Endocrinology,
379*(1–2), 30–34.

## License

MIT — see [`LICENSE`](LICENSE).
