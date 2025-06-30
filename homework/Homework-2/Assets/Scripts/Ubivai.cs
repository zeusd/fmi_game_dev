using UnityEngine;

public class Ubivai : MonoBehaviour
{
    //[SerializeField]
    private Kruv irgra4;

    // Start is called once before the first execution of Update after the MonoBehaviour is created
    void Start()
    {
        irgra4 = GameObject.FindGameObjectWithTag("Player").GetComponent<Kruv>();
    }

    // Update is called once per frame
    void Update()
    {

    }

    void OnTriggerEnter2D(Collider2D col)
    {
        if (col.CompareTag("Player"))
        {
            irgra4.Umri();
        }
    }
}
