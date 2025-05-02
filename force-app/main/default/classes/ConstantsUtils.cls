/**
 * @description       : 
 * @author            : Subramani Kumarasamy
 * @group             : 
 * @last modified on  : 05-01-2025
 * @last modified by  : Subramani Kumarasamy
**/
public with sharing class ConstantsUtils {
    public static final Decimal LEAD_ACCOUNT_MATCH_THRESHOLD;
    static {
        try {
            LEAD_ACCOUNT_MATCH_THRESHOLD = Decimal.valueOf(Label.LeadMatchingThreshold);
        } catch (Exception e) {
            // Default to a safe value 60.0
            LEAD_ACCOUNT_MATCH_THRESHOLD = 60.0;
        }
    }
    public static final String NOISE_WORDS = Label.NoiseWords;

}