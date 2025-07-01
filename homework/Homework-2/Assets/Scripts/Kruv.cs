using UnityEngine;

public class Kruv : MonoBehaviour
{
    private int kruv;
    private int kliu4owe;

    Vector2 na4alo;

    [SerializeField]
    int max_kruv;

    // Start is called once before the first execution of Update after the MonoBehaviour is created
    void Start()
    {
        na4alo = transform.position;
        kruv = max_kruv;
    }

    // Update is called once per frame
    void Update()
    {

    }

    public int Kolko()
    {
        return kliu4owe;
    }

    public void Vzemi()
    {
        kliu4owe += 1;
    }

    public void Umri()
    {
        transform.position = na4alo;
    }
}
