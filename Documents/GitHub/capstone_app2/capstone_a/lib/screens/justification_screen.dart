import 'package:flutter/material.dart';

class JustificationScreen extends StatelessWidget {
  const JustificationScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Justification'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Disclaimer',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'This application provides sizing information to assist in thoracic transplant decision-making. The models and data presented are intended for informational purposes only and should not be used as the sole basis for clinical decisions. Transplant suitability and donor-recipient matching require comprehensive clinical evaluation, incorporating all relevant medical history, imaging, hemodynamic parameters, and expert judgment.',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            const Text(
              'Healthcare providers should exercise clinical discretion and consider all available recipient-specific information before making transplant-related decisions. The developers of this application assume no responsibility for clinical outcomes resulting from its use.',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            const Text(
              'By using this application, you acknowledge that qualified healthcare professionals should make final medical decisions based on a holistic assessment of each case.',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 32),
            const Text(
              'Definitions to know:',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Absolute Risk - the actual chance (or probability) of an event happening in a population. It is usually expressed as a percentage.',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            const Text(
              'Relative Risk - compares the risk of an event occurring in one group to another group. It is a ratio that helps determine whether an exposure or intervention increases or decreases risk compared to a control group.',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            const Text(
              'A high relative risk can sound alarming, but the absolute risk helps put it in perspective.',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 32),
            const Text(
              'Justification',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Two separate regression equations– pTLC (predicted Total Lung Capacity) and pHM (predicted Heart Mass) – are used for our application, both derived from allometric regression models based on data from 1,746 healthy patients without metabolic or cardiovascular conditions.',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            const Text(
              'Predicted Total Lung Capacity (pTLC):',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'pTLC for men = [7.99 × height in meters] - 7.08\n'
              'pTLC for women = [6.60 × height in meters] - 5.79\n'
              'pTLC ratio = pTLC Donor / pTLC Recipient',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            const Text(
              'These equations were developed using data from nonsmokers with no diseases affecting lung function. They are applicable to adults (ages 18–70) of European descent, within the following height ranges:',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 8),
            const Text(
              'Men: 1.55–1.95 m\n'
              'Women: 1.45–1.80 m',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            const Text(
              'Predicted Heart Mass (pHM):',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Predicted left ventricular mass (g) = a × Height^0.54 × Weight^0.51\n'
              'a = 6.82 for women and 8.25 for men\n\n'
              'Predicted right ventricular mass (g) = a × Age^-0.32 × Height^1.135 × Weight^0.315\n'
              'a = 10.59 for women and 11.25 for men\n\n'
              'pHM Ratio = (pHM Recipient - pHM Donor) / pHM recipient × 100',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            const Text(
              'The equations for left and right ventricular mass were derived using multiplicative models by regressing the log-transformed ventricular mass against the log of height, weight, and (for right ventricular mass) age and sex.',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 32),
            const Text(
              'References:',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildReference(
              'Bluemke, D. A., Kronmal, R. A., Joao A.C. Lima, Liu, K., Olson, J. L., Burke, G. L., & Folsom, A. R. (2008). The Relationship of Left Ventricular Mass and Geometry to Incident Cardiovascular Events. Journal of the American College of Cardiology, 52(25), 2148–2155.',
              'https://doi.org/10.1016/j.jacc.2008.09.014',
            ),
            const SizedBox(height: 16),
            _buildReference(
              'Eberlein, M., & Reed, R. M. (2016). Donor to recipient sizing in thoracic organ transplantation. World Journal of Transplantation, 6(1), 155.',
              'https://doi.org/10.5500/wjt.v6.i1.155',
            ),
            const SizedBox(height: 16),
            _buildReference(
              'Eduard Ródenas-Alesina, Foroutan, F., Fan, C.-P., Stehlik, J., Bartlett, I., Maxime Tremblay-Gravel, Aleksova, N., Rao, V., Miller, R. J. H., Khush, K. K., Ross, H. J., & Yasbanoo Moayedi. (2023). Predicted Heart Mass: A Tale of 2 Ventricles. Circulation Heart Failure, 16(9).',
              'https://doi.org/10.1161/circheartfailure.120.008311',
            ),
            const SizedBox(height: 16),
            _buildReference(
              'Kawut, S. M., Lima, J. A. C., Barr, R. G., Chahal, H., Jain, A., Tandri, H., Praestgaard, A., Bagiella, E., Kizer, J. R., Johnson, W. C., Kronmal, R. A., & Bluemke, D. A. (2011). Sex and Race Differences in Right Ventricular Structure and Function. Circulation, 123(22), 2542–2551.',
              'https://doi.org/10.1161/circulationaha.110.985515',
            ),
            const SizedBox(height: 16),
            _buildReference(
              'Quanjer, P. H., Tammeling, G. J., Cotes, J. E., Pedersen, O. F., Peslin, R., & Yernault, J.-C. (1993). Lung Volumes and Forced Ventilatory Flows. European Respiratory Journal, 6(Suppl 16), 21.',
              'https://doi.org/10.1183/09041950.005s1693',
            ),
            const SizedBox(height: 16),
            _buildReference(
              'Reed, R. M., Netzer, G., Hunsicker, L. G., Mitchell, B. D., Rajagopal, K., Scharf, S. M., & Eberlein, M. (2014). Cardiac Size and Sex-Matching in Heart Transplantation. JACC: Heart Failure, 2(1), 73–83.',
              'https://doi.org/10.1016/j.jchf.2013.09.005',
            ),
            const SizedBox(height: 32),
            const Text(
              'Lung Relative Risk Chart',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Image.asset(
              'assets/images/lunggraph.png',
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 8),
            const Text(
              'Eberlein, M., & Reed, R. M. (2016). Donor to recipient sizing in thoracic organ transplantation. World Journal of Transplantation, 6(1), 155. https://doi.org/10.5500/wjt.v6.i1.155',
              style: TextStyle(
                fontSize: 12,
                fontStyle: FontStyle.italic,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'For more information, kindly refer to the following articles:',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'https://www.wjgnet.com/2220-3230/full/v6/i1/155.htm',
              style: TextStyle(
                fontSize: 14,
                color: Colors.blue,
                decoration: TextDecoration.underline,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Eberlein, M., & Reed, R. M. (2016). Donor to recipient sizing in thoracic organ transplantation. World journal of transplantation, 6(1), 155–164. https://doi.org/10.5500/wjt.v6.i1.155',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 16),
            const Text(
              'The article "Donor to recipient sizing in thoracic organ transplantation" by Dr Eberlein and Dr Reed discusses the importance of matching donor and recipient sizes, particularly focusing on the predicted total lung capacity (pTLC) ratio. This ratio is calculated by dividing the donor\'s pTLC by the recipient\'s pTLC.',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            const Text(
              'The authors present a graph illustrating the relationship between the pTLC ratio and relative risk (RR) of primary graft dysfunction (PGD). This graph is crucial for understanding how size mismatches between donor and recipient can influence transplant outcomes.',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            const Text(
              'Key Insights from the Graph:',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Optimal pTLC Ratio Range: The graph indicates that a pTLC ratio between 0.85 and 1.15 is associated with the lowest relative risk of PGD. This range suggests that donor-recipient size matching within this window is ideal for minimizing complications.',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 8),
            const Text(
              'Increased Risk with Mismatches: Deviations from this optimal range, either smaller or larger, lead to an increased relative risk of PGD. For instance, a pTLC ratio below 0.85 or above 1.15 corresponds to higher relative risks, indicating that both undersized and oversized grafts can compromise transplant success.',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            const Text(
              'Clinical implications:',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Incorporating the pTLC ratio into donor-recipient matching protocols can enhance the precision of transplant planning. By aiming for a pTLC ratio within the optimal range, clinicians can reduce the likelihood of PGD and improve overall transplant outcomes. This approach underscores the importance of personalized matching strategies in thoracic organ transplantation.',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 32),
            const Text(
              'Heart Size Matching and Graft Failure Risk',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Image.asset(
              'assets/images/heartgraph.png',
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 16),
            const Text(
              'For more information, kindly refer to the following articles:',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'https://www.ahajournals.org/doi/10.1161/CIRCHEARTFAILURE.120.008311',
              style: TextStyle(
                fontSize: 14,
                color: Colors.blue,
                decoration: TextDecoration.underline,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Ródenas-Alesina, E., Foroutan, F., Fan, C.-P., Stehlik, J., Bartlett, I., Tremblay-Gravel, M., Aleksova, N., Rao, V., Miller, R. J. H., Khush, K. K., Ross, H. J., & Moayedi, Y. (2023). Predicted heart mass: A tale of 2 Ventricles. Circulation: Heart Failure, 16(9). https://doi.org/10.1161/circheartfailure.120.008311',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 16),
            const Text(
              'In the study "Predicted Heart Mass: A Tale of 2 Ventricles" by Reed et al., the authors investigate the relationship between donor-recipient heart size matching and the risk of graft failure following heart transplantation. They utilize the Predicted Heart Mass (PHM) metric, assessing both left ventricular (LV) and right ventricular (RV) contributions separately, to refine donor-recipient matching.',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            const Text(
              'Understanding the Hazard Ratio (HR) in This Context:',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'A hazard ratio is a measure used in survival analyses to compare the risk of a particular event (in this case, graft failure) occurring at any point in time between two groups. An HR greater than 1 indicates an increased risk, while an HR less than 1 suggests a decreased risk.',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            const Text(
              'Key Findings Regarding LV and RV PHM Differences:',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Left Ventricular (LV) Undersizing:',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'The study found that a donor LV undersized by more than 26% relative to the recipient was associated with a 1.5-fold increased risk of graft failure. This suggests that significant LV undersizing compromises transplant outcomes.',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            const Text(
              'Right Ventricular (RV) Oversizing:',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Similarly, a donor RV oversized by more than 40% relative to the recipient also conferred a 1.5-fold increased risk of graft failure. This highlights the risks associated with substantial RV oversizing.',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            const Text(
              'Clinical implications:',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'The study emphasizes that both LV and RV size mismatches can independently affect transplant success. Therefore, incorporating separate assessments of LV and RV PHM differences, rather than relying solely on total heart mass, can enhance the precision of donor-recipient matching. This approach aims to minimize the risk of graft failure and improve post-transplant outcomes.',
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReference(String text, String url) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          text,
          style: const TextStyle(fontSize: 16),
        ),
        const SizedBox(height: 4),
        Text(
          url,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.blue,
            decoration: TextDecoration.underline,
          ),
        ),
      ],
    );
  }
} 