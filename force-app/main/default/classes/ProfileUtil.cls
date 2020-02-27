public class ProfileUtil {
    public static Profile getCurrentUserProfile() {
        Id profileId = UserInfo.getProfileId();
        return [SELECT Id, Name FROM Profile WHERE Id = :profileId];
    }
}