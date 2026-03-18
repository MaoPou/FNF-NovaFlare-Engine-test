package general.backend.device;

// make Sscript can check those data
#if android
import android.os.AppDetails;

class AppData
{
	public static function getVersionName():String
	{
		return AppDetails.getVersionName();
	}

	public static function getVersionCode():Int
	{
		return AppDetails.getVersionCode();
	}

	public static function getPackageName():String
	{
		return AppDetails.getPackageName();
	}

	public static function getAppName():String
	{
		return AppDetails.getAppName();
	}
	
	public static function verifySignature():Bool
	{
		return AppDetails.verifySignature();
	}
}
#end
