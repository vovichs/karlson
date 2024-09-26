using UnityEngine;

public class Bounce : MonoBehaviour
{
	private void OnCollisionEnter(Collision other)
	{
		MonoBehaviour.print("yeet");
		bool flag = (bool)other.gameObject.GetComponent<Rigidbody>();
	}
}
