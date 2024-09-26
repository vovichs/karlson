using EZCameraShake;
using UnityEngine;

public class ShakeOnKeyPress : MonoBehaviour
{
	public float Magnitude = 2f;

	public float Roughness = 10f;

	public float FadeOutTime = 5f;

	private void Update()
	{
		if (UnityEngine.Input.GetKeyDown(KeyCode.LeftShift))
		{
			CameraShaker.Instance.ShakeOnce(Magnitude, Roughness, 0f, FadeOutTime);
		}
	}
}
