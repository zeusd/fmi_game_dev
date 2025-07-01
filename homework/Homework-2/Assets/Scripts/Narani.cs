using UnityEngine;

public class Narani : MonoBehaviour
{
    private Kruv igra4;

    // Start is called once before the first execution of Update after the MonoBehaviour is created
    void Start()
    {
        igra4 = GameObject.FindGameObjectWithTag("Player").GetComponent<Kruv>();
    }

    // Update is called once per frame
    void Update()
    {

    }

    void OnTriggerEnter2D(Collider2D col)
    {
        if (col.CompareTag("Player"))
        {
            igra4.Narani();
        }
    }
}
